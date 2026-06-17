"""
=============================================================================
 SEMANTIC GRAPH — Biểu diễn Semantic Relationships
=============================================================================
 Biểu diễn mối quan hệ ngữ nghĩa giữa Triệu chứng ↔ Chuyên khoa ↔ Bác sĩ
 dưới dạng đồ thị có hướng có trọng số (Directed Weighted Graph).

 Các loại quan hệ (Relation Types):
   - HAS_SYMPTOM       : Khoa có triệu chứng   (Department → Symptom)
   - TREATED_BY        : Triệu chứng được điều trị bởi (Symptom → Department)
   - WORKS_IN          : Bác sĩ làm việc tại   (Doctor → Department)
   - SPECIALIZES_IN    : Bác sĩ chuyên về triệu chứng (Doctor → Symptom)
   - RELATED_TO        : Khoa liên quan đến khoa khác (Department ↔ Department)
   - INDICATES         : Triệu chứng gợi ý bệnh (Symptom → Disease)
   - MANAGED_BY        : Bệnh được quản lý bởi khoa (Disease → Department)
=============================================================================
"""

import logging
from dataclasses import dataclass, field
from enum import Enum
from typing import List, Dict, Optional, Set, Tuple
from collections import defaultdict

logger = logging.getLogger(__name__)


# ─── Relation Types ───────────────────────────────────────────────────────────

class RelationType(Enum):
    HAS_SYMPTOM    = "has_symptom"
    TREATED_BY     = "treated_by"
    WORKS_IN       = "works_in"
    SPECIALIZES_IN = "specializes_in"
    RELATED_TO     = "related_to"
    INDICATES      = "indicates"
    MANAGED_BY     = "managed_by"


# ─── Node & Edge ──────────────────────────────────────────────────────────────

class NodeType(Enum):
    SYMPTOM    = "symptom"
    DEPARTMENT = "department"
    DOCTOR     = "doctor"
    DISEASE    = "disease"


@dataclass
class Node:
    id: str
    node_type: NodeType
    label: str                         # tên hiển thị tiếng Việt
    metadata: dict = field(default_factory=dict)


@dataclass
class Edge:
    source_id: str
    target_id: str
    relation: RelationType
    weight: float = 1.0               # trọng số quan hệ (0-1)
    metadata: dict = field(default_factory=dict)


# ─── Semantic Graph ───────────────────────────────────────────────────────────

class SemanticGraph:
    """
    Đồ thị ngữ nghĩa biểu diễn toàn bộ tri thức y tế.

    Cấu trúc:
      nodes: dict[id → Node]
      edges: list[Edge]
      adj:   dict[source_id → list[Edge]]  (adjacency list)
    """

    def __init__(self):
        self.nodes: Dict[str, Node] = {}
        self.edges: List[Edge] = []
        self._adj: Dict[str, List[Edge]] = defaultdict(list)
        self._radj: Dict[str, List[Edge]] = defaultdict(list)  # reverse

    # ── Add ───────────────────────────────────────────────────────────────────

    def add_node(self, node: Node):
        self.nodes[node.id] = node

    def add_edge(self, edge: Edge):
        self.edges.append(edge)
        self._adj[edge.source_id].append(edge)
        self._radj[edge.target_id].append(edge)

    def add_relation(self, src: str, tgt: str, rel: RelationType, weight: float = 1.0, **meta):
        self.add_edge(Edge(src, tgt, rel, weight, metadata=meta))

    # ── Query ─────────────────────────────────────────────────────────────────

    def neighbors(self, node_id: str, relation: Optional[RelationType] = None) -> List[Node]:
        """Trả về các node kề (outgoing edges) từ node_id."""
        edges = self._adj.get(node_id, [])
        if relation:
            edges = [e for e in edges if e.relation == relation]
        return [self.nodes[e.target_id] for e in edges if e.target_id in self.nodes]

    def incoming(self, node_id: str, relation: Optional[RelationType] = None) -> List[Node]:
        """Trả về các node có cạnh vào node_id (reverse lookup)."""
        edges = self._radj.get(node_id, [])
        if relation:
            edges = [e for e in edges if e.relation == relation]
        return [self.nodes[e.source_id] for e in edges if e.source_id in self.nodes]

    def get_doctors_for_dept(self, dept_id: str) -> List[Node]:
        """Tìm tất cả bác sĩ thuộc một chuyên khoa."""
        return self.incoming(dept_id, RelationType.WORKS_IN)

    def get_related_depts(self, dept_id: str) -> List[Node]:
        """Chuyên khoa liên quan."""
        return self.neighbors(dept_id, RelationType.RELATED_TO)

    def get_symptoms_for_dept(self, dept_id: str) -> List[Node]:
        """Các triệu chứng mà khoa điều trị."""
        return self.neighbors(dept_id, RelationType.HAS_SYMPTOM)

    def get_dept_for_symptom(self, symptom_id: str) -> List[Tuple[Node, float]]:
        """Tìm khoa điều trị triệu chứng, kèm trọng số."""
        edges = [e for e in self._adj.get(symptom_id, [])
                 if e.relation == RelationType.TREATED_BY]
        result = []
        for e in edges:
            if e.target_id in self.nodes:
                result.append((self.nodes[e.target_id], e.weight))
        result.sort(key=lambda x: x[1], reverse=True)
        return result

    def bfs_path(self, start_id: str, target_type: NodeType, max_depth: int = 3) -> List[Node]:
        """BFS tìm các node đích (theo loại) từ một node nguồn."""
        visited: Set[str] = set()
        queue = [(start_id, 0)]
        result = []
        while queue:
            nid, depth = queue.pop(0)
            if nid in visited or depth > max_depth:
                continue
            visited.add(nid)
            node = self.nodes.get(nid)
            if node and node.node_type == target_type and nid != start_id:
                result.append(node)
            for edge in self._adj.get(nid, []):
                if edge.target_id not in visited:
                    queue.append((edge.target_id, depth + 1))
        return result

    def semantic_search(self, symptom_ids: List[str]) -> List[dict]:
        """
        Tìm kiếm ngữ nghĩa: từ danh sách triệu chứng → xếp hạng chuyên khoa.
        Tổng hợp trọng số từ tất cả cạnh TREATED_BY.
        """
        dept_scores: Dict[str, float] = defaultdict(float)
        dept_nodes: Dict[str, Node] = {}

        for sym_id in symptom_ids:
            for dept_node, weight in self.get_dept_for_symptom(sym_id):
                dept_scores[dept_node.id] += weight
                dept_nodes[dept_node.id] = dept_node

        ranked = sorted(dept_scores.items(), key=lambda x: x[1], reverse=True)
        results = []
        for dept_id, score in ranked[:5]:
            node = dept_nodes[dept_id]
            doctors = self.get_doctors_for_dept(dept_id)
            related = self.get_related_depts(dept_id)
            results.append({
                "dept_id": dept_id,
                "dept_name": node.label,
                "score": round(score, 2),
                "doctors": [{"id": d.id, "name": d.label, **d.metadata} for d in doctors],
                "related_depts": [r.label for r in related],
            })
        return results

    def explain_path(self, symptom_id: str, dept_id: str) -> str:
        """Giải thích mối quan hệ ngữ nghĩa giữa triệu chứng và chuyên khoa."""
        sym = self.nodes.get(symptom_id)
        dept = self.nodes.get(dept_id)
        if not sym or not dept:
            return "Không tìm thấy quan hệ."
        edges = [e for e in self._adj.get(symptom_id, [])
                 if e.target_id == dept_id and e.relation == RelationType.TREATED_BY]
        if edges:
            w = edges[0].weight
            return (f"Triệu chứng [{sym.label}] có quan hệ TREATED_BY với "
                    f"[{dept.label}] (trọng số: {w:.1f})")
        return f"Không có quan hệ trực tiếp giữa [{sym.label}] và [{dept.label}]."


# ─── Builder: nạp dữ liệu vào Semantic Graph ─────────────────────────────────

def build_semantic_graph() -> SemanticGraph:
    """
    Khởi tạo và nạp toàn bộ tri thức y tế vào SemanticGraph.
    Biểu diễn đầy đủ quan hệ ngữ nghĩa:
      Symptom --TREATED_BY--> Department
      Department --HAS_SYMPTOM--> Symptom
      Doctor --WORKS_IN--> Department
      Doctor --SPECIALIZES_IN--> Symptom
      Department --RELATED_TO--> Department
    """
    g = SemanticGraph()

    # ══ 1. DEPARTMENT NODES ══════════════════════════════════════════════════
    depts = [
        ("dept_than_kinh",   "Khoa Thần kinh"),
        ("dept_tim_mach",    "Khoa Tim mạch"),
        ("dept_ho_hap",      "Khoa Hô hấp"),
        ("dept_tieu_hoa",    "Khoa Tiêu hóa"),
        ("dept_co_xuong_khop","Khoa Cơ Xương Khớp"),
        ("dept_noi_tiet",    "Khoa Nội tiết"),
        ("dept_da_lieu",     "Khoa Da liễu"),
        ("dept_mat",         "Khoa Mắt"),
        ("dept_tai_mui_hong","Khoa Tai Mũi Họng"),
        ("dept_tiet_nieu",   "Khoa Tiết niệu"),
        ("dept_san_phu",     "Khoa Sản Phụ khoa"),
        ("dept_nhi",         "Khoa Nhi"),
        ("dept_tam_than",    "Khoa Tâm thần"),
        ("dept_noi_tq",      "Khoa Nội tổng quát"),
    ]
    for did, label in depts:
        g.add_node(Node(did, NodeType.DEPARTMENT, label))

    # ══ 2. SYMPTOM NODES ════════════════════════════════════════════════════
    symptoms = [
        ("dau_dau",            "Đau đầu"),
        ("chong_mat",          "Chóng mặt"),
        ("buon_non",           "Buồn nôn"),
        ("non",                "Nôn"),
        ("mat_ngu",            "Mất ngủ"),
        ("lo_au",              "Lo âu"),
        ("tram_cam",           "Trầm cảm"),
        ("te_bi",              "Tê bì"),
        ("yeu_liet",           "Yếu liệt"),
        ("co_giat",            "Co giật"),
        ("nhay_cam_anh_sang",  "Nhạy cảm ánh sáng"),
        ("dau_nguc",           "Đau ngực"),
        ("kho_tho",            "Khó thở"),
        ("tim_dap_nhanh",      "Tim đập nhanh"),
        ("hoi_hop",            "Hồi hộp"),
        ("phu_chan",           "Phù chân"),
        ("huyet_ap_cao",       "Huyết áp cao"),
        ("met_moi",            "Mệt mỏi"),
        ("sot",                "Sốt"),
        ("sot_cao",            "Sốt cao"),
        ("ho_keo_dai",         "Ho kéo dài"),
        ("co_dom",             "Có đờm"),
        ("tho_kho_khe",        "Thở khò khè"),
        ("ho_ra_mau",          "Ho ra máu"),
        ("so_mui",             "Sổ mũi"),
        ("hat_hoi",            "Hắt hơi"),
        ("dau_hong",           "Đau họng"),
        ("dau_bung",           "Đau bụng"),
        ("dau_thuong_vi",      "Đau thượng vị"),
        ("o_chua",             "Ợ chua"),
        ("tieu_chay",          "Tiêu chảy"),
        ("dau_quan_bung",      "Đau quặn bụng"),
        ("vang_da",            "Vàng da"),
        ("vang_mat",           "Vàng mắt"),
        ("dau_lung",           "Đau lưng"),
        ("cung_khop",          "Cứng khớp"),
        ("sung_khop",          "Sưng khớp"),
        ("dau_khop_goi",       "Đau khớp gối"),
        ("dau_co",             "Đau cổ"),
        ("khat_nuoc",          "Khát nước nhiều"),
        ("tieu_nhieu",         "Tiểu nhiều"),
        ("tang_can",           "Tăng cân"),
        ("cam_thay_lanh",      "Cảm thấy lạnh"),
        ("noi_man",            "Nổi mẩn"),
        ("ngua",               "Ngứa"),
        ("mun_trung_ca",       "Mụn trứng cá"),
        ("da_nhon",            "Da nhờn"),
        ("mo_mat",             "Mờ mắt"),
        ("dau_mat",            "Đau mắt"),
        ("do_mat",             "Đỏ mắt"),
        ("tieu_buot",          "Tiểu buốt"),
        ("nuoc_tieu_duc",      "Nước tiểu đục"),
        ("dau_bung_duoi",      "Đau bụng dưới"),
        ("kinh_nguyet_bat_thuong", "Kinh nguyệt bất thường"),
        ("phat_ban",           "Phát ban"),
        ("quay_khoc",          "Quấy khóc"),
    ]
    for sid, label in symptoms:
        g.add_node(Node(sid, NodeType.SYMPTOM, label))

    # ══ 3. DOCTOR NODES ════════════════════════════════════════════════════
    doctors = [
        # (id, name, dept_id, title, experience, rating)
        ("dr_001", "Nguyễn Văn An",    "dept_than_kinh",    "PGS.TS", 20, 4.8),
        ("dr_002", "Trần Thị Bình",    "dept_than_kinh",    "ThS.BS", 12, 4.6),
        ("dr_003", "Lê Minh Cường",    "dept_tim_mach",     "GS.TS",  25, 4.9),
        ("dr_004", "Phạm Thị Dung",    "dept_tim_mach",     "TS.BS",  18, 4.7),
        ("dr_005", "Hoàng Văn Em",     "dept_ho_hap",       "ThS.BS", 10, 4.5),
        ("dr_006", "Vũ Thị Phương",    "dept_ho_hap",       "BS.CKI", 8,  4.4),
        ("dr_007", "Đặng Minh Quân",   "dept_tieu_hoa",     "PGS.TS", 22, 4.8),
        ("dr_008", "Bùi Thị Hương",    "dept_tieu_hoa",     "ThS.BS", 14, 4.6),
        ("dr_009", "Ngô Văn Hùng",     "dept_co_xuong_khop","TS.BS",  16, 4.7),
        ("dr_010", "Đinh Thị Lan",     "dept_co_xuong_khop","BS.CKII",13, 4.5),
        ("dr_011", "Trương Minh Kha",  "dept_noi_tiet",     "TS.BS",  15, 4.7),
        ("dr_012", "Lý Thị Mai",       "dept_da_lieu",      "BS.CKI", 9,  4.5),
        ("dr_013", "Phan Văn Nam",     "dept_mat",          "ThS.BS", 11, 4.6),
        ("dr_014", "Cao Thị Oanh",     "dept_tai_mui_hong", "BS.CKII",14, 4.6),
        ("dr_015", "Vương Minh Phúc",  "dept_tiet_nieu",    "PGS.TS", 20, 4.8),
        ("dr_016", "Hà Thị Quỳnh",    "dept_san_phu",      "GS.TS",  24, 4.9),
        ("dr_017", "Tô Minh Thắng",   "dept_nhi",          "TS.BS",  17, 4.8),
        ("dr_018", "Châu Thị Uyên",   "dept_tam_than",     "ThS.BS", 12, 4.5),
        ("dr_019", "Dương Văn Việt",  "dept_noi_tq",       "BS.CKI", 7,  4.3),
        ("dr_020", "Mã Thị Xuân",     "dept_noi_tq",       "ThS.BS", 10, 4.4),
    ]
    for did, name, dept, title, exp, rating in doctors:
        g.add_node(Node(did, NodeType.DOCTOR, name, {
            "title": title,
            "experience_years": exp,
            "rating": rating,
            "department": dept
        }))

    # ══ 4. EDGES: Symptom --TREATED_BY--> Department ════════════════════════
    treated_by = [
        # (symptom_id, dept_id, weight)
        ("dau_dau",           "dept_than_kinh",     0.9),
        ("chong_mat",         "dept_than_kinh",     0.8),
        ("chong_mat",         "dept_tai_mui_hong",  0.5),
        ("buon_non",          "dept_tieu_hoa",      0.7),
        ("buon_non",          "dept_than_kinh",     0.5),
        ("non",               "dept_tieu_hoa",      0.8),
        ("mat_ngu",           "dept_than_kinh",     0.7),
        ("mat_ngu",           "dept_tam_than",      0.8),
        ("lo_au",             "dept_tam_than",      0.9),
        ("lo_au",             "dept_than_kinh",     0.6),
        ("tram_cam",          "dept_tam_than",      0.95),
        ("te_bi",             "dept_than_kinh",     0.9),
        ("te_bi",             "dept_co_xuong_khop", 0.6),
        ("yeu_liet",          "dept_than_kinh",     0.95),
        ("co_giat",           "dept_than_kinh",     0.98),
        ("nhay_cam_anh_sang", "dept_than_kinh",     0.85),
        ("dau_nguc",          "dept_tim_mach",      0.9),
        ("dau_nguc",          "dept_ho_hap",        0.5),
        ("kho_tho",           "dept_ho_hap",        0.85),
        ("kho_tho",           "dept_tim_mach",      0.7),
        ("tim_dap_nhanh",     "dept_tim_mach",      0.9),
        ("hoi_hop",           "dept_tim_mach",      0.85),
        ("phu_chan",          "dept_tim_mach",      0.8),
        ("huyet_ap_cao",      "dept_tim_mach",      0.9),
        ("met_moi",           "dept_noi_tq",        0.6),
        ("met_moi",           "dept_noi_tiet",      0.5),
        ("sot",               "dept_noi_tq",        0.7),
        ("sot_cao",           "dept_nhi",           0.8),
        ("sot_cao",           "dept_noi_tq",        0.6),
        ("ho_keo_dai",        "dept_ho_hap",        0.9),
        ("co_dom",            "dept_ho_hap",        0.8),
        ("tho_kho_khe",       "dept_ho_hap",        0.9),
        ("ho_ra_mau",         "dept_ho_hap",        0.95),
        ("so_mui",            "dept_tai_mui_hong",  0.85),
        ("hat_hoi",           "dept_tai_mui_hong",  0.8),
        ("dau_hong",          "dept_tai_mui_hong",  0.9),
        ("dau_bung",          "dept_tieu_hoa",      0.85),
        ("dau_thuong_vi",     "dept_tieu_hoa",      0.9),
        ("o_chua",            "dept_tieu_hoa",      0.9),
        ("tieu_chay",         "dept_tieu_hoa",      0.85),
        ("dau_quan_bung",     "dept_tieu_hoa",      0.8),
        ("vang_da",           "dept_tieu_hoa",      0.95),
        ("vang_mat",          "dept_tieu_hoa",      0.95),
        ("dau_lung",          "dept_co_xuong_khop", 0.85),
        ("cung_khop",         "dept_co_xuong_khop", 0.9),
        ("sung_khop",         "dept_co_xuong_khop", 0.9),
        ("dau_khop_goi",      "dept_co_xuong_khop", 0.9),
        ("dau_co",            "dept_co_xuong_khop", 0.8),
        ("khat_nuoc",         "dept_noi_tiet",      0.85),
        ("tieu_nhieu",        "dept_noi_tiet",      0.85),
        ("tieu_nhieu",        "dept_tiet_nieu",     0.7),
        ("tang_can",          "dept_noi_tiet",      0.7),
        ("cam_thay_lanh",     "dept_noi_tiet",      0.7),
        ("noi_man",           "dept_da_lieu",       0.9),
        ("ngua",              "dept_da_lieu",       0.85),
        ("mun_trung_ca",      "dept_da_lieu",       0.9),
        ("da_nhon",           "dept_da_lieu",       0.7),
        ("mo_mat",            "dept_mat",           0.9),
        ("dau_mat",           "dept_mat",           0.9),
        ("do_mat",            "dept_mat",           0.85),
        ("tieu_buot",         "dept_tiet_nieu",     0.9),
        ("nuoc_tieu_duc",     "dept_tiet_nieu",     0.9),
        ("dau_bung_duoi",     "dept_san_phu",       0.8),
        ("dau_bung_duoi",     "dept_tieu_hoa",      0.5),
        ("kinh_nguyet_bat_thuong", "dept_san_phu",  0.95),
        ("phat_ban",          "dept_da_lieu",       0.8),
        ("phat_ban",          "dept_nhi",           0.7),
        ("quay_khoc",         "dept_nhi",           0.8),
    ]
    for sym_id, dept_id, w in treated_by:
        g.add_relation(sym_id, dept_id, RelationType.TREATED_BY, w)
        g.add_relation(dept_id, sym_id, RelationType.HAS_SYMPTOM, w)

    # ══ 5. EDGES: Doctor --WORKS_IN--> Department ═══════════════════════════
    for did, name, dept, title, exp, rating in doctors:
        g.add_relation(did, dept, RelationType.WORKS_IN, 1.0)

    # ══ 6. EDGES: Doctor --SPECIALIZES_IN--> Symptom ═══════════════════════
    specializations = [
        ("dr_001", ["dau_dau", "chong_mat", "co_giat", "yeu_liet"]),
        ("dr_002", ["mat_ngu", "lo_au", "te_bi"]),
        ("dr_003", ["dau_nguc", "tim_dap_nhanh", "huyet_ap_cao"]),
        ("dr_004", ["phu_chan", "kho_tho", "hoi_hop"]),
        ("dr_005", ["ho_keo_dai", "kho_tho", "tho_kho_khe"]),
        ("dr_007", ["dau_thuong_vi", "o_chua", "vang_da"]),
        ("dr_009", ["dau_lung", "sung_khop", "cung_khop"]),
        ("dr_011", ["khat_nuoc", "tieu_nhieu", "tang_can"]),
        ("dr_016", ["dau_bung_duoi", "kinh_nguyet_bat_thuong"]),
        ("dr_017", ["sot_cao", "phat_ban", "quay_khoc"]),
        ("dr_018", ["lo_au", "tram_cam", "mat_ngu"]),
    ]
    for dr_id, syms in specializations:
        for sym_id in syms:
            g.add_relation(dr_id, sym_id, RelationType.SPECIALIZES_IN, 0.9)

    # ══ 7. EDGES: Department --RELATED_TO--> Department ═════════════════════
    related = [
        ("dept_than_kinh",    "dept_tam_than",      0.7),
        ("dept_than_kinh",    "dept_co_xuong_khop", 0.5),
        ("dept_tim_mach",     "dept_noi_tiet",      0.6),
        ("dept_tim_mach",     "dept_ho_hap",        0.6),
        ("dept_ho_hap",       "dept_tai_mui_hong",  0.7),
        ("dept_tieu_hoa",     "dept_noi_tiet",      0.5),
        ("dept_co_xuong_khop","dept_than_kinh",     0.5),
        ("dept_noi_tiet",     "dept_tim_mach",      0.6),
        ("dept_tam_than",     "dept_than_kinh",     0.7),
        ("dept_nhi",          "dept_noi_tq",        0.6),
        ("dept_san_phu",      "dept_noi_tiet",      0.5),
    ]
    for src, tgt, w in related:
        g.add_relation(src, tgt, RelationType.RELATED_TO, w)

    return g


# ─── Singleton instance ───────────────────────────────────────────────────────
_graph_instance: Optional[SemanticGraph] = None

def get_semantic_graph() -> SemanticGraph:
    global _graph_instance
    if _graph_instance is None:
        _graph_instance = build_semantic_graph()
    return _graph_instance


def load_dynamic_graph_nodes(db_rules: List[dict], graph: SemanticGraph):
    """Nạp các nút triệu chứng và quan hệ ngữ nghĩa từ CSDL Supabase vào Semantic Graph."""
    added_nodes = 0
    added_edges = 0

    for r in db_rules:
        sid = r.get("symptom_id")
        dept_name = r.get("department_name")
        conf = r.get("confidence", 85)

        if not sid or not dept_name:
            continue

        if sid not in graph.nodes:
            kws_str = r.get("symptom_keywords", "")
            first_kw = kws_str.split(",")[0].strip().capitalize() if kws_str else sid
            graph.add_node(Node(sid, NodeType.SYMPTOM, first_kw))
            added_nodes += 1

        matching_dept_ids = [
            nid for nid, node in graph.nodes.items()
            if node.node_type == NodeType.DEPARTMENT and (node.label.lower() == dept_name.lower() or dept_name.lower() in node.label.lower())
        ]

        weight = (int(conf) if conf is not None else 85) / 100.0

        for dept_id in matching_dept_ids:
            existing_edges = [
                e for e in graph.edges
                if e.source_id == sid and e.target_id == dept_id and e.relation == RelationType.TREATED_BY
            ]
            if not existing_edges:
                graph.add_relation(sid, dept_id, RelationType.TREATED_BY, weight)
                graph.add_relation(dept_id, sid, RelationType.HAS_SYMPTOM, weight)
                added_edges += 2

    logger.info("✅ Dynamic Graph elements loaded from DB: added %d symptom nodes, %d relations", added_nodes, added_edges)
