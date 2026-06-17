"""
=============================================================================
 PRODUCTION RULES ENGINE — Knowledge Representation
=============================================================================
 Biểu diễn tri thức y tế bằng Production Rules (Luật sản xuất):
   FORMAT:  IF <điều kiện triệu chứng> THEN <chuyên khoa> WITH <độ tin cậy>

 Cấu trúc:
   - ProductionRule   : một luật IF-THEN
   - RuleEngine       : forward-chaining inference engine
   - WorkingMemory    : bộ nhớ làm việc (các fact hiện tại)
=============================================================================
"""

import logging
from dataclasses import dataclass, field
from typing import List, Dict, Callable, Optional

logger = logging.getLogger(__name__)


# ─── Cấu trúc một Rule ────────────────────────────────────────────────────────

@dataclass
class ProductionRule:
    """
    Một luật sản xuất y tế:
      id          : định danh luật
      name        : tên mô tả
      conditions  : list các symptom_id cần khớp (AND logic)
      department  : chuyên khoa kết luận
      confidence  : độ tin cậy (0-100)
      priority    : ưu tiên khi nhiều luật cùng kích hoạt (cao hơn = ưu tiên hơn)
      advice      : lời khuyên tương ứng
      secondary   : chuyên khoa phụ (nếu có)
    """
    id: str
    name: str
    conditions: List[str]           # symptom_id list
    department: str
    confidence: int
    priority: int = 1
    advice: str = ""
    secondary: Optional[str] = None


@dataclass
class WorkingMemory:
    """Bộ nhớ làm việc chứa các fact (triệu chứng đã nhận dạng)."""
    facts: List[str] = field(default_factory=list)   # symptom_id list

    def add(self, symptom_id: str):
        if symptom_id not in self.facts:
            self.facts.append(symptom_id)

    def contains(self, symptom_id: str) -> bool:
        return symptom_id in self.facts

    def match_conditions(self, conditions: List[str], require_all: bool = False) -> int:
        """Trả về số điều kiện khớp. require_all=True → AND logic."""
        matched = sum(1 for c in conditions if c in self.facts)
        if require_all and matched < len(conditions):
            return 0
        return matched


@dataclass
class RuleFiring:
    """Kết quả khi một luật được kích hoạt."""
    rule: ProductionRule
    matched_count: int
    total_conditions: int
    effective_confidence: int

    @property
    def match_ratio(self) -> float:
        return self.matched_count / max(self.total_conditions, 1)


# ─── Rule Engine (Forward Chaining) ──────────────────────────────────────────

class ProductionRuleEngine:
    """
    Forward-Chaining Inference Engine.

    Thuật toán:
      1. Nạp tất cả ProductionRule vào rule base
      2. Từ WorkingMemory (symptoms), tìm các luật được kích hoạt (conflict set)
      3. Chọn luật tốt nhất theo: priority → confidence → match_ratio
      4. Trả về kết quả tư vấn
    """

    def __init__(self):
        self.rules: List[ProductionRule] = []

    def add_rule(self, rule: ProductionRule):
        self.rules.append(rule)

    def add_rules(self, rules: List[ProductionRule]):
        self.rules.extend(rules)

    def fire(self, wm: WorkingMemory, top_k: int = 3) -> List[RuleFiring]:
        """
        Kích hoạt các luật phù hợp với WorkingMemory.
        Trả về top-k RuleFiring sắp xếp theo độ ưu tiên.
        """
        fired: List[RuleFiring] = []

        for rule in self.rules:
            matched = wm.match_conditions(rule.conditions)
            if matched == 0:
                continue

            ratio = matched / len(rule.conditions)
            # Giảm confidence nếu chỉ khớp một phần điều kiện
            eff_conf = int(rule.confidence * ratio)
            if eff_conf < 20:
                continue

            fired.append(RuleFiring(
                rule=rule,
                matched_count=matched,
                total_conditions=len(rule.conditions),
                effective_confidence=eff_conf
            ))

        # Conflict resolution:
        #   1. match_ratio DESC  — luật khớp đủ điều kiện hơn được ưu tiên
        #   2. priority DESC     — luật có priority cao hơn thắng
        #   3. effective_confidence DESC — confidence cao hơn thắng
        fired.sort(key=lambda f: (
            f.match_ratio,
            f.rule.priority,
            f.effective_confidence,
        ), reverse=True)

        return fired[:top_k]

    def infer(self, symptom_ids: List[str]) -> Optional[dict]:
        """
        API chính: nhận list symptom_id → trả về dict kết quả.
        """
        wm = WorkingMemory(facts=symptom_ids)
        results = self.fire(wm, top_k=3)

        if not results:
            return None

        best = results[0]
        secondary = None
        if len(results) > 1 and results[1].rule.department != best.rule.department:
            secondary = results[1].rule.department

        return {
            "department": best.rule.department,
            "confidence": best.effective_confidence,
            "summary": f"Dựa trên {best.matched_count}/{best.total_conditions} triệu chứng khớp với luật \"{best.rule.name}\".",
            "advice": best.rule.advice,
            "secondary_department": secondary or best.rule.secondary,
            "matched_rules": [r.rule.name for r in results],
        }


# ─── Định nghĩa toàn bộ Production Rules y tế ────────────────────────────────

def build_medical_rules() -> List[ProductionRule]:
    """
    Trả về danh sách đầy đủ các Production Rules y tế.

    Mỗi luật theo dạng:
      IF [triệu chứng A, triệu chứng B, ...] THEN <chuyên khoa> WITH confidence=N
    """
    return [

        # ══════════════════════════════════════════════════════════════════════
        # KHOA THẦN KINH
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R001",
            name="Đau đầu + chóng mặt → Thần kinh",
            conditions=["dau_dau", "chong_mat"],
            department="Khoa Thần kinh",
            confidence=85, priority=3,
            secondary="Khoa Nội tổng quát",
            advice="• Nghỉ ngơi đầy đủ, tránh ánh sáng mạnh\n• Uống đủ nước (2-2.5 lít/ngày)\n• Tránh căng thẳng, stress\n• Đo huyết áp kiểm tra"
        ),
        ProductionRule(
            id="R002",
            name="Đau đầu + buồn nôn + nhạy cảm ánh sáng → Thần kinh (Migraine)",
            conditions=["dau_dau", "buon_non", "nhay_cam_anh_sang"],
            department="Khoa Thần kinh",
            confidence=90, priority=4,
            advice="• Nằm nghỉ nơi yên tĩnh, tối\n• Chườm lạnh trán\n• Uống thuốc đau đầu theo chỉ định\n• Tái khám nếu >3 lần/tuần"
        ),
        ProductionRule(
            id="R003",
            name="Tê bì + yếu liệt tay chân → Thần kinh",
            conditions=["te_bi", "yeu_liet"],
            department="Khoa Thần kinh",
            confidence=92, priority=5,
            advice="• Đến cơ sở y tế NGAY\n• Không tự uống thuốc\n• Ghi lại thời điểm xuất hiện triệu chứng"
        ),
        ProductionRule(
            id="R004",
            name="Mất ngủ + lo âu → Thần kinh/Tâm thần",
            conditions=["mat_ngu", "lo_au"],
            department="Khoa Thần kinh",
            confidence=78, priority=2,
            secondary="Khoa Tâm thần",
            advice="• Duy trì lịch ngủ đều đặn\n• Hạn chế caffeine sau 14h\n• Thực hành thiền định, hít thở sâu\n• Tham vấn chuyên gia tâm lý"
        ),
        ProductionRule(
            id="R005",
            name="Co giật → Thần kinh",
            conditions=["co_giat"],
            department="Khoa Thần kinh",
            confidence=95, priority=5,
            advice="• GỌI CẤP CỨU NGAY (115)\n• Đặt bệnh nhân nằm nghiêng\n• Không giữ chặt hoặc đưa vật vào miệng"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA TIM MẠCH
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R010",
            name="Đau ngực + khó thở → Tim mạch",
            conditions=["dau_nguc", "kho_tho"],
            department="Khoa Tim mạch",
            confidence=90, priority=5,
            advice="• Gọi cấp cứu nếu đau dữ dội\n• Nghỉ ngơi, không gắng sức\n• Nới lỏng quần áo\n• Theo dõi nhịp tim"
        ),
        ProductionRule(
            id="R011",
            name="Tim đập nhanh + hồi hộp → Tim mạch",
            conditions=["tim_dap_nhanh", "hoi_hop"],
            department="Khoa Tim mạch",
            confidence=85, priority=3,
            advice="• Đo nhịp tim và huyết áp\n• Tránh chất kích thích (cà phê, thuốc lá)\n• Thở đều, ngồi nghỉ\n• Đo điện tim (ECG)"
        ),
        ProductionRule(
            id="R012",
            name="Phù chân + khó thở + mệt mỏi → Tim mạch",
            conditions=["phu_chan", "kho_tho", "met_moi"],
            department="Khoa Tim mạch",
            confidence=88, priority=4,
            advice="• Nâng cao chân khi nằm\n• Hạn chế muối trong chế độ ăn\n• Siêu âm tim ngay\n• Không tự ý ngừng thuốc"
        ),
        ProductionRule(
            id="R013",
            name="Huyết áp cao + đau đầu → Tim mạch",
            conditions=["huyet_ap_cao", "dau_dau"],
            department="Khoa Tim mạch",
            confidence=87, priority=4,
            secondary="Khoa Thần kinh",
            advice="• Đo huyết áp ngay\n• Ngồi nghỉ 5-10 phút\n• Uống thuốc huyết áp theo chỉ định\n• Đến viện nếu >180/120 mmHg"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA HÔ HẤP
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R020",
            name="Ho kéo dài + đờm + sốt → Hô hấp",
            conditions=["ho_keo_dai", "co_dom", "sot"],
            department="Khoa Hô hấp",
            confidence=88, priority=4,
            advice="• Uống nhiều nước ấm\n• Xông mũi họng\n• X-quang phổi nếu ho >2 tuần\n• Tránh khói bụi"
        ),
        ProductionRule(
            id="R021",
            name="Khó thở + thở khò khè → Hô hấp",
            conditions=["kho_tho", "tho_kho_khe"],
            department="Khoa Hô hấp",
            confidence=90, priority=4,
            advice="• Ngồi thẳng, thở chậm sâu\n• Dùng thuốc giãn phế quản (nếu có)\n• Đến cơ sở y tế nếu không cải thiện\n• Đo SpO2"
        ),
        ProductionRule(
            id="R022",
            name="Ho ra máu → Hô hấp (khẩn cấp)",
            conditions=["ho_ra_mau"],
            department="Khoa Hô hấp",
            confidence=95, priority=5,
            advice="• ĐẾN BỆNH VIỆN NGAY\n• Không ăn uống trước khi khám\n• Nằm nghiêng để tránh sặc"
        ),
        ProductionRule(
            id="R023",
            name="Sổ mũi + hắt hơi + đau họng → Tai Mũi Họng",
            conditions=["so_mui", "hat_hoi", "dau_hong"],
            department="Khoa Tai Mũi Họng",
            confidence=82, priority=3,
            advice="• Súc họng nước muối ấm\n• Xịt mũi sinh lý\n• Uống nhiều nước ấm\n• Nghỉ ngơi, tránh lạnh"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA TIÊU HÓA
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R030",
            name="Đau bụng + buồn nôn + nôn → Tiêu hóa",
            conditions=["dau_bung", "buon_non", "non"],
            department="Khoa Tiêu hóa",
            confidence=85, priority=3,
            advice="• Nhịn ăn 4-6 tiếng nếu nôn nhiều\n• Uống ORS bù điện giải\n• Tránh thức ăn dầu mỡ, cay\n• Đến viện nếu đau >6h"
        ),
        ProductionRule(
            id="R031",
            name="Đau thượng vị + ợ chua → Tiêu hóa (dạ dày)",
            conditions=["dau_thuong_vi", "o_chua"],
            department="Khoa Tiêu hóa",
            confidence=88, priority=3,
            advice="• Ăn chậm, nhai kỹ\n• Không nằm ngay sau ăn\n• Hạn chế cà phê, rượu bia\n• Nội soi dạ dày để chẩn đoán"
        ),
        ProductionRule(
            id="R032",
            name="Tiêu chảy + đau quặn bụng → Tiêu hóa",
            conditions=["tieu_chay", "dau_quan_bung"],
            department="Khoa Tiêu hóa",
            confidence=83, priority=3,
            advice="• Bù nước điện giải (ORS)\n• Ăn cháo trắng, chuối\n• Rửa tay thường xuyên\n• Đến viện nếu tiêu chảy >3 ngày"
        ),
        ProductionRule(
            id="R033",
            name="Vàng da + vàng mắt → Tiêu hóa (Gan)",
            conditions=["vang_da", "vang_mat"],
            department="Khoa Tiêu hóa",
            confidence=93, priority=5,
            advice="• ĐẾN BỆNH VIỆN NGAY\n• Xét nghiệm chức năng gan\n• Siêu âm bụng\n• Tránh rượu bia hoàn toàn"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA CƠ XƯƠNG KHỚP
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R040",
            name="Đau lưng + cứng khớp sáng → Cơ Xương Khớp",
            conditions=["dau_lung", "cung_khop"],
            department="Khoa Cơ Xương Khớp",
            confidence=84, priority=3,
            advice="• Chườm nóng/lạnh xen kẽ\n• Tập vật lý trị liệu\n• Tránh mang vác nặng\n• Chụp X-quang cột sống"
        ),
        ProductionRule(
            id="R041",
            name="Sưng khớp + đau khớp gối → Cơ Xương Khớp",
            conditions=["sung_khop", "dau_khop_goi"],
            department="Khoa Cơ Xương Khớp",
            confidence=87, priority=3,
            advice="• Nghỉ ngơi, nâng cao chân\n• Chườm đá (15 phút x 3 lần/ngày)\n• Siêu âm khớp\n• Tránh đứng lâu"
        ),
        ProductionRule(
            id="R042",
            name="Đau cổ + tê tay → Cơ Xương Khớp (Cột sống cổ)",
            conditions=["dau_co", "te_bi"],
            department="Khoa Cơ Xương Khớp",
            confidence=83, priority=3,
            secondary="Khoa Thần kinh",
            advice="• Điều chỉnh tư thế ngồi làm việc\n• Tập cơ cổ nhẹ nhàng\n• Chụp MRI cột sống cổ\n• Tránh cúi đầu lâu"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA NỘI TIẾT
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R050",
            name="Khát nước nhiều + tiểu nhiều + mệt mỏi → Nội tiết (Đái tháo đường)",
            conditions=["khat_nuoc", "tieu_nhieu", "met_moi"],
            department="Khoa Nội tiết",
            confidence=90, priority=4,
            advice="• Xét nghiệm đường huyết ngay\n• Theo dõi lượng nước uống\n• Hạn chế đường, tinh bột\n• Kiểm tra cân nặng"
        ),
        ProductionRule(
            id="R051",
            name="Tăng cân + mệt + lạnh → Nội tiết (Giáp)",
            conditions=["tang_can", "met_moi", "cam_thay_lanh"],
            department="Khoa Nội tiết",
            confidence=82, priority=3,
            advice="• Xét nghiệm TSH, T3, T4\n• Siêu âm tuyến giáp\n• Vận động thường xuyên\n• Kiểm tra hormone định kỳ"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA DA LIỄU
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R060",
            name="Nổi mẩn + ngứa → Da liễu",
            conditions=["noi_man", "ngua"],
            department="Khoa Da liễu",
            confidence=85, priority=3,
            advice="• Tránh gãi để tránh bội nhiễm\n• Dùng kem dưỡng ẩm\n• Tránh tiếp xúc chất gây dị ứng\n• Test dị ứng da"
        ),
        ProductionRule(
            id="R061",
            name="Mụn trứng cá + da nhờn → Da liễu",
            conditions=["mun_trung_ca", "da_nhon"],
            department="Khoa Da liễu",
            confidence=88, priority=2,
            advice="• Rửa mặt 2 lần/ngày\n• Không tự nặn mụn\n• Dùng sản phẩm không gây bít lỗ chân lông\n• Xét nghiệm nội tiết nếu cần"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA MẮT
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R070",
            name="Mờ mắt + đau mắt + đỏ mắt → Mắt",
            conditions=["mo_mat", "dau_mat", "do_mat"],
            department="Khoa Mắt",
            confidence=90, priority=4,
            advice="• Không dụi mắt\n• Nhỏ nước muối sinh lý\n• Đo thị lực ngay\n• Tránh ánh sáng mạnh"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA TIẾT NIỆU
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R080",
            name="Đau tiểu + tiểu buốt + nước tiểu đục → Tiết niệu",
            conditions=["tieu_buot", "nuoc_tieu_duc"],
            department="Khoa Tiết niệu",
            confidence=88, priority=4,
            advice="• Uống nhiều nước (3 lít/ngày)\n• Xét nghiệm nước tiểu\n• Siêu âm thận-bàng quang\n• Tránh nhịn tiểu"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA SẢN PHỤ KHOA
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R090",
            name="Đau bụng dưới + kinh nguyệt bất thường → Sản Phụ khoa",
            conditions=["dau_bung_duoi", "kinh_nguyet_bat_thuong"],
            department="Khoa Sản Phụ khoa",
            confidence=87, priority=4,
            advice="• Ghi lại chu kỳ kinh nguyệt\n• Siêu âm vùng chậu\n• Xét nghiệm nội tiết\n• Không tự ý dùng thuốc nội tiết"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA NHI
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R100",
            name="Trẻ sốt cao + phát ban + quấy khóc → Nhi khoa",
            conditions=["sot_cao", "phat_ban", "quay_khoc"],
            department="Khoa Nhi",
            confidence=90, priority=4,
            advice="• Hạ sốt bằng paracetamol đúng liều\n• Chườm ấm\n• Bổ sung nước/điện giải\n• Đến viện nếu sốt >39°C"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # KHOA TÂM THẦN
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R110",
            name="Lo âu + trầm cảm + mất ngủ kéo dài → Tâm thần",
            conditions=["lo_au", "tram_cam", "mat_ngu"],
            department="Khoa Tâm thần",
            confidence=88, priority=4,
            advice="• Nói chuyện với người thân tin cậy\n• Liệu pháp nhận thức hành vi (CBT)\n• Tránh rượu bia\n• Gặp chuyên gia tâm lý"
        ),

        # ══════════════════════════════════════════════════════════════════════
        # NỘI TỔNG QUÁT (fallback)
        # ══════════════════════════════════════════════════════════════════════
        ProductionRule(
            id="R200",
            name="Sốt + mệt mỏi → Nội tổng quát",
            conditions=["sot", "met_moi"],
            department="Khoa Nội tổng quát",
            confidence=70, priority=1,
            advice="• Nghỉ ngơi đầy đủ\n• Uống nhiều nước\n• Hạ sốt nếu >38.5°C\n• Xét nghiệm máu tổng quát"
        ),
        ProductionRule(
            id="R201",
            name="Triệu chứng đơn lẻ → Nội tổng quát",
            conditions=["met_moi"],
            department="Khoa Nội tổng quát",
            confidence=60, priority=1,
            advice="• Xét nghiệm máu tổng quát\n• Kiểm tra sức khỏe định kỳ\n• Bổ sung vitamin và khoáng chất\n• Nghỉ ngơi đủ giấc"
        ),
        ProductionRule(
            id="R120",
            name="Sụt cân không rõ lý do → Nội tổng quát",
            conditions=["sut_can"],
            department="Khoa Nội tổng quát",
            confidence=70, priority=2,
            advice="• Xét nghiệm máu tổng quát\n• Kiểm tra tuyến giáp, đường huyết\n• Siêu âm ổ bụng"
        ),
        ProductionRule(
            id="R121",
            name="Mồ hôi đêm + mệt mỏi → Nội tổng quát",
            conditions=["mo_hoi_nhieu", "met_moi"],
            department="Khoa Nội tổng quát",
            confidence=72, priority=2,
            advice="• Xét nghiệm công thức máu\n• Kiểm tra tuyến giáp\n• Đo đường huyết lúc đói"
        ),
        ProductionRule(
            id="R122",
            name="Sưng khớp gối → Cơ Xương Khớp",
            conditions=["sung_khop"],
            department="Khoa Cơ Xương Khớp",
            confidence=75, priority=3,
            advice="• Chườm đá 15 phút x 3 lần/ngày\n• Hạn chế đứng lâu\n• Siêu âm khớp\n• Dùng thuốc kháng viêm theo chỉ định"
        ),
        ProductionRule(
            id="R123",
            name="Chấn thương / té ngã → Ngoại khoa",
            conditions=["chan_thuong"],
            department="Khoa Ngoại",
            confidence=88, priority=4,
            advice="• Đến phòng cấp cứu ngay\n• Chụp X-quang vùng bị thương\n• Không tự nắn khớp"
        ),
        ProductionRule(
            id="R124",
            name="Đau bụng cấp → Ngoại khoa",
            conditions=["dau_bung_cap"],
            department="Khoa Ngoại",
            confidence=90, priority=5,
            advice="• GỌI CẤP CỨU NGAY (115)\n• Không ăn uống\n• Không uống thuốc giảm đau trước khi khám"
        ),
        ProductionRule(
            id="R125",
            name="Ù tai / Nghe kém → Tai Mũi Họng",
            conditions=["u_tai"],
            department="Khoa Tai Mũi Họng",
            confidence=82, priority=3,
            advice="• Đo thính lực\n• Tránh tiếng ồn lớn\n• Không tự nhỏ thuốc tai\n• Đến khám sớm"
        ),
        ProductionRule(
            id="R126",
            name="Đỏ mắt + đau mắt → Mắt",
            conditions=["do_mat", "dau_mat"],
            department="Khoa Mắt",
            confidence=85, priority=3,
            advice="• Không dụi mắt\n• Nhỏ nước mắt nhân tạo\n• Đến khám nhãn khoa ngay"
        ),
        ProductionRule(
            id="R127",
            name="Khí hư bất thường → Sản Phụ khoa",
            conditions=["khi_hu"],
            department="Khoa Sản Phụ khoa",
            confidence=80, priority=3,
            advice="• Giữ vệ sinh vùng kín\n• Không tự dùng thuốc đặt\n• Xét nghiệm dịch âm đạo"
        ),
        ProductionRule(
            id="R128",
            name="Sốt + quấy khóc → Nhi khoa",
            conditions=["sot", "quay_khoc"],
            department="Khoa Nhi",
            confidence=85, priority=4,
            advice="• Hạ sốt bằng paracetamol đúng liều\n• Chườm ấm\n• Bổ sung nước điện giải\n• Đến viện nếu sốt > 38.5°C"
        ),
    ]


def load_dynamic_rules(db_rules: List[dict], engine: ProductionRuleEngine):
    """Khởi tạo và đăng ký các ProductionRule từ CSDL Supabase vào Engine."""
    added_count = 0
    existing_ids = {r.id for r in engine.rules}

    for r in db_rules:
        rid = r.get("rule_id")
        rname = r.get("rule_name")
        sid = r.get("symptom_id")
        dept = r.get("department_name")
        conf = r.get("confidence", 85)
        prio = r.get("priority", 2)
        adv = r.get("advice", "")

        if not rid or not rname or not sid or not dept:
            continue

        if rid in existing_ids:
            continue

        rule = ProductionRule(
            id=rid,
            name=rname,
            conditions=[sid],
            department=dept,
            confidence=int(conf) if conf is not None else 85,
            priority=int(prio) if prio is not None else 2,
            advice=adv or ""
        )
        engine.add_rule(rule)
        existing_ids.add(rid)
        added_count += 1

    logger.info("✅ Dynamic Production Rules loaded from DB: added %d rules", added_count)
