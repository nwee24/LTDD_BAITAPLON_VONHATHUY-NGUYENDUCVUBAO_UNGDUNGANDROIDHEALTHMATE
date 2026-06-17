"""
=============================================================================
 HEALTHMATE AI BACKEND — FastAPI
=============================================================================
 Kiến trúc Knowledge Representation:
   1. Symptom Extractor  → nhận dạng triệu chứng từ văn bản tự nhiên
   2. Production Rules   → forward-chaining IF-THEN inference
   3. Semantic Graph     → semantic search + lấy thông tin bác sĩ

 Luồng xử lý:
   [Văn bản bệnh nhân]
       ↓ SymptomExtractor.extract_symptom_ids()
   [Danh sách symptom_id]
       ↓ ProductionRuleEngine.infer()          ← Knowledge Representation
       ↓ SemanticGraph.semantic_search()       ← Semantic Relationships
   [Kết quả tổng hợp] → JSON response → Android App
=============================================================================
"""

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Optional, List
import uvicorn
import logging

from knowledge_base.production_rules import ProductionRuleEngine, build_medical_rules, load_dynamic_rules
from knowledge_base.semantic_graph import get_semantic_graph, SemanticGraph, Node, NodeType, Edge, RelationType, load_dynamic_graph_nodes
from knowledge_base.symptom_extractor import extract_symptom_ids, describe_extracted, load_dynamic_keywords
from knowledge_base.supabase_loader import (
    fetch_chuyen_khoa, fetch_bac_si, fetch_ai_training_rules,
    normalize_dept_name, build_dept_id, build_doctor_id
)

# ─── Logging ──────────────────────────────────────────────────────────────────
logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
logger = logging.getLogger(__name__)

# ─── FastAPI App ───────────────────────────────────────────────────────────────
app = FastAPI(
    title="HealthMate AI Consultation API",
    description=(
        "Backend tư vấn y tế sử dụng Knowledge Representation (Production Rules) "
        "và Semantic Relationships để ánh xạ triệu chứng → chuyên khoa → bác sĩ."
    ),
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ─── Khởi tạo Engine (singleton) ──────────────────────────────────────────────
_rule_engine = ProductionRuleEngine()
_rule_engine.add_rules(build_medical_rules())
_graph = get_semantic_graph()


def _load_db_into_graph(graph):
    """
    Fetch khoa + bác sĩ thật từ Supabase, nạp vào Semantic Graph.
    - Khoa DB được ánh xạ → normalized name khớp với Production Rules
    - Bác sĩ DB được liên kết với khoa tương ứng qua WORKS_IN
    """
    khoa_list = fetch_chuyen_khoa()
    bac_si_list = fetch_bac_si()

    # Map ma_khoa → normalized dept name
    ma_to_normalized = {}
    ma_to_node_id = {}

    for k in khoa_list:
        ma = k["ma_khoa"]
        node_id = build_dept_id(ma)
        normalized = normalize_dept_name(k["ten_khoa"])
        ma_to_normalized[ma] = normalized

        # Kiểm tra đã có node với tên này chưa
        existing = next(
            (n for n in graph.nodes.values()
             if n.node_type == NodeType.DEPARTMENT and n.label == normalized),
            None
        )
        if existing:
            # Trỏ alias DB id → node hiện có, đánh dấu from_db
            existing.metadata["from_db"] = True
            existing.metadata["ma_khoa"] = ma
            graph.nodes[node_id] = existing
            ma_to_node_id[ma] = existing.id
        else:
            graph.add_node(Node(node_id, NodeType.DEPARTMENT, normalized, {
                "ma_khoa": ma,
                "mo_ta": k.get("mo_ta", ""),
                "anh_icon_url": k.get("anh_icon_url", ""),
                "from_db": True,
            }))
            ma_to_node_id[ma] = node_id

    for b in bac_si_list:
        ma_bs  = b["ma_bac_si"]
        ma_khoa = b["ma_khoa"]
        dr_id  = build_doctor_id(ma_bs)
        dept_node_id = ma_to_node_id.get(ma_khoa)

        graph.add_node(Node(dr_id, NodeType.DOCTOR, b["ho_ten"], {
            "title":            b.get("hoc_vi") or "BS",
            "experience_years": 0,
            "rating":           float(b.get("danh_gia") or 4.0),
            "department":       ma_to_normalized.get(ma_khoa, "Khoa Nội tổng quát"),
            "ma_bac_si":        ma_bs,
            "ma_khoa":          ma_khoa,
            "chi_tiet":         b.get("chi_tiet_chuyen_mon") or "",
            "anh_url":          b.get("anh_chan_dung_url") or "",
            "is_db":            True,
        }))

        if dept_node_id and dept_node_id in graph.nodes:
            graph.add_relation(dr_id, dept_node_id, RelationType.WORKS_IN, 1.0)

    logger.info("✅ Supabase loaded: %d khoa, %d bac si", len(khoa_list), len(bac_si_list))


_load_db_into_graph(_graph)


def load_all_dynamic_ai_knowledge():
    """Tải và nạp toàn bộ dữ liệu tri thức động từ Supabase vào các cấu trúc bộ nhớ AI."""
    logger.info("🔄 Bắt đầu nạp tri thức động từ Supabase...")
    db_rules = fetch_ai_training_rules()
    if db_rules:
        logger.info("📦 Lấy thành công %d bộ quy tắc/dữ liệu huấn luyện từ Supabase", len(db_rules))
        load_dynamic_keywords(db_rules)
        load_dynamic_rules(db_rules, _rule_engine)
        load_dynamic_graph_nodes(db_rules, _graph)
    else:
        logger.warning("⚠️ Không lấy được dữ liệu tri thức từ Supabase hoặc bảng trống.")


load_all_dynamic_ai_knowledge()
logger.info("✅ Production Rules Engine: %d rules loaded", len(_rule_engine.rules))
logger.info("✅ Semantic Graph: %d nodes, %d edges", len(_graph.nodes), len(_graph.edges))

# ─── Tập hợp tên khoa có trong DB (dùng để filter kết quả) ──────────────────
_DB_DEPT_NAMES: set = set()

# Danh sách các khoa chuẩn mặc định có trong hệ thống (dùng làm mốc an toàn)
_STANDARD_DEPTS = {
    "Khoa Thần kinh", "Khoa Tim mạch", "Khoa Nội tiết", "Khoa Hô hấp",
    "Khoa Tiêu hóa", "Khoa Cơ Xương Khớp", "Khoa Da liễu", "Khoa Tiết niệu",
    "Khoa Mắt", "Khoa Nhi", "Khoa Ngoại", "Khoa Tai Mũi Họng",
    "Khoa Sản Phụ khoa", "Khoa Tâm thần", "Khoa Ung bướu", "Khoa Nội tổng quát"
}

def _refresh_db_dept_names():
    """Cập nhật tập tên khoa DB từ Semantic Graph (sau mỗi lần load)."""
    global _DB_DEPT_NAMES
    _DB_DEPT_NAMES = {
        n.label for n in _graph.nodes.values()
        if n.node_type == NodeType.DEPARTMENT and n.metadata.get("from_db")
        or (n.node_type == NodeType.DEPARTMENT and any(
            d.metadata.get("is_db") for d in _graph.get_doctors_for_dept(n.id)
        ))
    }
    # Luôn đảm bảo các khoa DB thật từ Supabase đều có mặt
    for n in _graph.nodes.values():
        if n.node_type == NodeType.DEPARTMENT and n.metadata.get("from_db"):
            _DB_DEPT_NAMES.add(n.label)
    logger.info("✅ DB departments: %s", sorted(_DB_DEPT_NAMES))

_refresh_db_dept_names()

# Ánh xạ khoa KHÔNG có trong DB → khoa gần nhất có trong DB
_DEPT_FALLBACK_MAP = {
    "Khoa Thần kinh":       "Khoa Nội khoa",
    "Khoa Tim mạch":        "Khoa Nội khoa",
    "Khoa Hô hấp":          "Khoa Nội khoa",
    "Khoa Tiêu hóa":        "Khoa Nội khoa",
    "Khoa Nội tiết":        "Khoa Nội khoa",
    "Khoa Tâm thần":        "Khoa Nội khoa",
    "Khoa Nội tổng quát":   "Khoa Nội khoa",
    "Khoa Cơ Xương Khớp":   "Khoa Ngoại khoa",
    "Khoa Tiết niệu":       "Khoa Ngoại khoa",
    "Khoa Ung bướu":        "Khoa Ngoại khoa",
}

def _map_to_db_dept(dept_name: str) -> str:
    """Nếu khoa không có trong DB, ánh xạ sang khoa DB gần nhất."""
    target_set = _DB_DEPT_NAMES.union(_STANDARD_DEPTS)
    # Kiểm tra tên chính xác
    for db_name in target_set:
        if dept_name.lower() in db_name.lower() or db_name.lower() in dept_name.lower():
            return db_name
    # Tra bảng fallback
    mapped = _DEPT_FALLBACK_MAP.get(dept_name)
    if mapped:
        for db_name in target_set:
            if mapped.lower() in db_name.lower() or db_name.lower() in mapped.lower():
                return db_name
    # Fallback cuối: Nội khoa
    for db_name in target_set:
        if "nội" in db_name.lower():
            return db_name
    # Trả về mặc định an toàn nếu vẫn không khớp
    return "Khoa Nội tổng quát"



# ─── Schemas ──────────────────────────────────────────────────────────────────

class ConsultRequest(BaseModel):
    symptoms: str = Field(
        ...,
        min_length=3,
        max_length=2000,
        description="Mô tả triệu chứng của bệnh nhân bằng tiếng Việt",
        example="Tôi bị đau đầu liên tục 3 ngày, kèm chóng mặt và buồn nôn."
    )


class DoctorInfo(BaseModel):
    id: str
    name: str
    title: str
    experience_years: int
    rating: float
    department: str


class ConsultResponse(BaseModel):
    department: str
    confidence: int
    summary: str
    advice: str
    secondary_department: Optional[str] = None
    # Extended fields (semantic graph)
    extracted_symptoms: List[str] = []
    recommended_doctors: List[DoctorInfo] = []
    related_departments: List[str] = []
    knowledge_method: str = "Production Rules + Semantic Graph"


class SymptomDebugResponse(BaseModel):
    input_text: str
    extracted_symptom_ids: List[str]
    extracted_symptom_names: str
    rule_inference: Optional[dict]
    semantic_results: List[dict]


# ─── Helpers ──────────────────────────────────────────────────────────────────

def _build_consult_response(
    symptom_ids: List[str],
    rule_result: Optional[dict],
    sem_results: List[dict],
) -> ConsultResponse:
    """
    Tổng hợp kết quả từ Production Rules + Semantic Graph thành response.

    Ưu tiên:
      - Nếu Production Rules trả về kết quả → dùng làm primary
      - Semantic Graph bổ sung thông tin bác sĩ + khoa liên quan
      - Nếu Rules không có kết quả → fallback hoàn toàn sang Semantic Graph
    """
    if rule_result:
        raw_dept    = rule_result["department"]
        dept_name   = _map_to_db_dept(raw_dept)   # ánh xạ sang khoa có trong DB
        confidence  = rule_result["confidence"]
        summary     = rule_result["summary"]
        if raw_dept != dept_name:
            summary += f" (Lưu ý: {raw_dept} hiện chưa có trong hệ thống, đề xuất khám tại {dept_name})"
        advice      = rule_result["advice"] or "• Đến gặp bác sĩ để được tư vấn cụ thể"
        secondary   = rule_result.get("secondary_department")
        if secondary:
            secondary = _map_to_db_dept(secondary)
    elif sem_results:
        top = sem_results[0]
        dept_name  = _map_to_db_dept(top["dept_name"])
        confidence = min(int(top["score"] * 60), 75)
        summary    = (f"Dựa trên phân tích ngữ nghĩa, triệu chứng của bạn "
                      f"phù hợp nhất với {dept_name}.")
        advice     = "• Liên hệ bác sĩ chuyên khoa để được thăm khám\n• Theo dõi và ghi chép triệu chứng"
        secondary  = _map_to_db_dept(sem_results[1]["dept_name"]) if len(sem_results) > 1 else None
    else:
        dept_name  = _map_to_db_dept("Khoa Nội tổng quát")
        confidence = 50
        summary    = "Không đủ thông tin để xác định chuyên khoa cụ thể."
        advice     = "• Đến Khoa Nội tổng quát để được khám và định hướng\n• Xét nghiệm máu tổng quát"
        secondary  = None

    # Lấy bác sĩ từ Semantic Graph — ưu tiên bác sĩ thật từ DB (is_db)
    matching_dept_nodes = [
        n for n in _graph.nodes.values()
        if n.node_type == NodeType.DEPARTMENT and n.label == dept_name
    ]
    doctors: List[DoctorInfo] = []
    related_depts: List[str] = []
    seen_dr_ids: set = set()

    for dept_node in matching_dept_nodes:
        for d in _graph.get_doctors_for_dept(dept_node.id):
            if d.id in seen_dr_ids:
                continue
            seen_dr_ids.add(d.id)
            doctors.append(DoctorInfo(
                id=d.id,
                name=d.label,
                title=d.metadata.get("title", "BS"),
                experience_years=d.metadata.get("experience_years", 0),
                rating=d.metadata.get("rating", 4.0),
                department=dept_name,
            ))
        if not related_depts:
            related_depts = [n.label for n in _graph.get_related_depts(dept_node.id)[:2]]

    # DB doctors trước, hardcoded sau
    db_docs    = [d for d in doctors if d.id.startswith("dr_db_")]
    other_docs = [d for d in doctors if not d.id.startswith("dr_db_")]
    doctors = (db_docs + other_docs)[:3]

    return ConsultResponse(
        department=dept_name,
        confidence=confidence,
        summary=summary,
        advice=advice,
        secondary_department=secondary,
        extracted_symptoms=symptom_ids,
        recommended_doctors=doctors,
        related_departments=related_depts,
        knowledge_method="Production Rules + Semantic Graph",
    )


# ─── Endpoints ────────────────────────────────────────────────────────────────

@app.get("/", tags=["Health"])
def root():
    return {
        "service": "HealthMate AI Consultation",
        "version": "2.0.0",
        "knowledge_methods": ["Production Rules", "Semantic Graph"],
        "status": "running",
    }


@app.get("/health", tags=["Health"])
def health():
    return {
        "status": "ok",
        "rules_count": len(_rule_engine.rules),
        "nodes_count": len(_graph.nodes),
        "edges_count": len(_graph.edges),
    }


@app.post("/consult", response_model=ConsultResponse, tags=["Consultation"])
def consult(req: ConsultRequest):
    """
    **Tư vấn AI chính** — nhận văn bản triệu chứng, trả về chuyên khoa + bác sĩ.

    Quy trình xử lý:
    1. **Symptom Extraction** — nhận dạng triệu chứng từ văn bản tự nhiên
    2. **Production Rules** — forward-chaining inference (IF symptoms THEN dept)
    3. **Semantic Graph** — tìm bác sĩ, khoa liên quan theo quan hệ ngữ nghĩa
    """
    logger.info("📥 Consult request: %.80s", req.symptoms)

    # Step 1: Extract symptoms
    symptom_ids = extract_symptom_ids(req.symptoms)
    logger.info("🔍 Extracted symptoms: %s", symptom_ids)

    if not symptom_ids:
        # Không nhận dạng được → trả về gợi ý khám tổng quát thay vì lỗi
        default_dept = _map_to_db_dept("Khoa Nội tổng quát")
        dept_node = next(
            (n for n in _graph.nodes.values()
             if n.node_type == NodeType.DEPARTMENT and n.label == default_dept), None
        )
        db_docs = []
        if dept_node:
            for d in _graph.get_doctors_for_dept(dept_node.id):
                if d.metadata.get("is_db"):
                    db_docs.append(DoctorInfo(
                        id=d.id, name=d.label,
                        title=d.metadata.get("title","BS"),
                        experience_years=d.metadata.get("experience_years",0),
                        rating=d.metadata.get("rating",4.0),
                        department=default_dept,
                    ))
        return ConsultResponse(
            department=default_dept,
            confidence=50,
            summary="Không nhận dạng được triệu chứng cụ thể từ mô tả của bạn.",
            advice=("• Vui lòng mô tả rõ hơn (ví dụ: đau đầu, sốt, khó thở...)\n"
                    "• Hoặc đến khám tổng quát để được bác sĩ định hướng\n"
                    "• Xét nghiệm máu tổng quát là bước đầu tiên phù hợp"),
            secondary_department=None,
            extracted_symptoms=[],
            recommended_doctors=db_docs[:3],
            related_departments=[],
            knowledge_method="Fallback — Không nhận dạng được triệu chứng",
        )

    # Step 2: Production Rules inference
    rule_result = _rule_engine.infer(symptom_ids)
    logger.info("📋 Rule result: %s", rule_result)

    # Step 3: Semantic Graph search
    sem_results = _graph.semantic_search(symptom_ids)
    logger.info("🕸️  Semantic results: %d depts found", len(sem_results))

    # Step 4: Build unified response
    response = _build_consult_response(symptom_ids, rule_result, sem_results)
    logger.info("✅ Response: %s (confidence=%d%%)", response.department, response.confidence)
    return response


@app.post("/consult/debug", response_model=SymptomDebugResponse, tags=["Debug"])
def consult_debug(req: ConsultRequest):
    """
    **Debug endpoint** — hiển thị chi tiết quá trình suy luận:
    - Triệu chứng nhận dạng được
    - Luật nào được kích hoạt (Production Rules)
    - Kết quả Semantic Graph
    """
    symptom_ids = extract_symptom_ids(req.symptoms)
    rule_result = _rule_engine.infer(symptom_ids) if symptom_ids else None
    sem_results = _graph.semantic_search(symptom_ids) if symptom_ids else []

    return SymptomDebugResponse(
        input_text=req.symptoms,
        extracted_symptom_ids=symptom_ids,
        extracted_symptom_names=describe_extracted(symptom_ids),
        rule_inference=rule_result,
        semantic_results=sem_results,
    )


@app.get("/departments", tags=["Knowledge"])
def list_departments():
    """Liệt kê tất cả chuyên khoa trong hệ thống."""
    depts = [
        {"id": n.id, "name": n.label}
        for n in _graph.nodes.values()
        if n.node_type.value == "department"
    ]
    return {"departments": depts, "count": len(depts)}


@app.get("/departments/{dept_id}/doctors", tags=["Knowledge"])
def get_dept_doctors(dept_id: str):
    """Lấy danh sách bác sĩ của một chuyên khoa."""
    if dept_id not in _graph.nodes:
        raise HTTPException(404, f"Không tìm thấy chuyên khoa: {dept_id}")
    doctors = _graph.get_doctors_for_dept(dept_id)
    return {
        "dept_id": dept_id,
        "dept_name": _graph.nodes[dept_id].label,
        "doctors": [{"id": d.id, "name": d.label, **d.metadata} for d in doctors],
    }


@app.get("/rules", tags=["Knowledge"])
def list_rules():
    """Liệt kê tất cả Production Rules trong hệ thống."""
    rules = [
        {
            "id": r.id,
            "name": r.name,
            "conditions": r.conditions,
            "department": r.department,
            "confidence": r.confidence,
            "priority": r.priority,
        }
        for r in _rule_engine.rules
    ]
    return {"rules": rules, "count": len(rules)}


@app.get("/semantic/explain", tags=["Knowledge"])
def explain_relation(symptom_id: str, dept_id: str):
    """Giải thích mối quan hệ ngữ nghĩa giữa một triệu chứng và chuyên khoa."""
    explanation = _graph.explain_path(symptom_id, dept_id)
    return {"symptom_id": symptom_id, "dept_id": dept_id, "explanation": explanation}


@app.get("/reload-ai-knowledge", tags=["Knowledge"])
def reload_ai_knowledge():
    """Tải lại nóng dữ liệu tri thức và quy tắc AI từ CSDL Supabase."""
    try:
        load_all_dynamic_ai_knowledge()
        # Gọi làm mới lại các tên khoa DB
        _refresh_db_dept_names()
        return {
            "status": "success",
            "message": "Nạp lại thành công tri thức AI từ Supabase",
            "rule_count": len(_rule_engine.rules),
            "node_count": len(_graph.nodes),
            "edge_count": len(_graph.edges),
        }
    except Exception as e:
        logger.error("Lỗi khi tải lại tri thức AI: %s", e)
        raise HTTPException(status_code=500, detail=f"Lỗi tải lại tri thức: {e}")


# ─── Entry point ──────────────────────────────────────────────────────────────
if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
