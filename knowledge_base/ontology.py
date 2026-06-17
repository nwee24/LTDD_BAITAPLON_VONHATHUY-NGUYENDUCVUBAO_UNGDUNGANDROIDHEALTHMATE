"""
=============================================================================
 MEDICAL DOMAIN ONTOLOGY — HealthMate Knowledge Representation
=============================================================================
 Mô-đun này định nghĩa ONTOLOGY miền y tế:
   - Các lớp thực thể (Symptom, Department, Doctor, Disease)
   - Thuộc tính (properties) của từng thực thể
   - Quan hệ phân cấp (is-a, part-of, related-to)

 Đây là tầng nền (TBox) cho hệ thống biểu diễn tri thức.
=============================================================================
"""

from dataclasses import dataclass, field
from enum import Enum
from typing import List, Optional


# ─── Enumerations ─────────────────────────────────────────────────────────────

class BodySystem(Enum):
    """Hệ cơ quan trong cơ thể người."""
    NERVOUS    = "Hệ thần kinh"
    CARDIO     = "Hệ tim mạch"
    RESPIRATORY= "Hệ hô hấp"
    DIGESTIVE  = "Hệ tiêu hóa"
    MUSCULO    = "Hệ cơ xương khớp"
    URINARY    = "Hệ tiết niệu"
    ENDOCRINE  = "Hệ nội tiết"
    SKIN       = "Da liễu"
    EYE        = "Mắt"
    ENT        = "Tai mũi họng"
    MENTAL     = "Tâm thần"
    PEDIATRIC  = "Nhi khoa"
    OBSTETRIC  = "Sản phụ khoa"
    ONCOLOGY   = "Ung bướu"
    GENERAL    = "Đa khoa"


class Severity(Enum):
    """Mức độ nghiêm trọng của triệu chứng."""
    MILD     = 1   # Nhẹ
    MODERATE = 2   # Trung bình
    SEVERE   = 3   # Nặng
    CRITICAL = 4   # Nguy kịch


class SymptomCategory(Enum):
    """Phân loại triệu chứng theo vùng cơ thể."""
    HEAD_NECK   = "Đầu cổ"
    CHEST       = "Ngực"
    ABDOMEN     = "Bụng"
    LIMBS       = "Tứ chi"
    BACK        = "Lưng"
    SKIN        = "Da"
    GENERAL     = "Toàn thân"
    SENSORY     = "Giác quan"
    MENTAL      = "Tâm thần"
    UROGENITAL  = "Tiết niệu sinh dục"


# ─── Entity Dataclasses ────────────────────────────────────────────────────────

@dataclass
class SymptomEntity:
    """
    Lớp thực thể TRIỆU CHỨNG (Symptom).
    Thuộc tính:
      - id            : định danh duy nhất (slug tiếng Việt không dấu)
      - name          : tên hiển thị tiếng Việt
      - keywords      : từ khóa nhận dạng trong văn bản người dùng
      - category      : phân loại vùng cơ thể
      - body_system   : hệ cơ quan liên quan
      - default_severity: mức độ nghiêm trọng mặc định
      - aliases       : tên gọi khác / tiếng lóng phổ thông
    """
    id: str
    name: str
    keywords: List[str]
    category: SymptomCategory
    body_system: BodySystem
    default_severity: Severity = Severity.MILD
    aliases: List[str] = field(default_factory=list)


@dataclass
class DepartmentEntity:
    """
    Lớp thực thể CHUYÊN KHOA (Department).
    Thuộc tính:
      - id            : định danh duy nhất
      - name          : tên tiếng Việt đầy đủ
      - body_system   : hệ cơ quan chính
      - short_desc    : mô tả ngắn
      - treats_symptoms: danh sách id triệu chứng điều trị
      - related_depts : chuyên khoa liên quan (quan hệ related-to)
    """
    id: str
    name: str
    body_system: BodySystem
    short_desc: str
    treats_symptoms: List[str] = field(default_factory=list)
    related_depts: List[str]   = field(default_factory=list)


@dataclass
class DoctorEntity:
    """
    Lớp thực thể BÁC SĨ (Doctor).
    Thuộc tính:
      - id            : định danh duy nhất
      - name          : họ tên bác sĩ
      - title         : học hàm/học vị (BS, ThS, TS, PGS, GS)
      - department_id : chuyên khoa chính
      - specialties   : danh sách chuyên sâu bổ sung
      - experience_years: số năm kinh nghiệm
      - rating        : điểm đánh giá (0-5)
    """
    id: str
    name: str
    title: str
    department_id: str
    specialties: List[str] = field(default_factory=list)
    experience_years: int = 0
    rating: float = 4.0


@dataclass
class DiseaseEntity:
    """
    Lớp thực thể BỆNH (Disease) — dùng để tăng cường suy luận.
    Thuộc tính:
      - id            : định danh
      - name          : tên bệnh
      - icd10         : mã ICD-10 (nếu có)
      - symptoms      : danh sách id triệu chứng đặc trưng
      - department_id : chuyên khoa điều trị chính
    """
    id: str
    name: str
    icd10: Optional[str]
    symptoms: List[str]
    department_id: str


# ─── Ontology Instance ─────────────────────────────────────────────────────────

class MedicalOntology:
    """
    Singleton chứa toàn bộ ontology miền y tế.
    Cho phép tra cứu thực thể theo id.
    """

    def __init__(self):
        self.symptoms:    dict[str, SymptomEntity]    = {}
        self.departments: dict[str, DepartmentEntity] = {}
        self.doctors:     dict[str, DoctorEntity]     = {}
        self.diseases:    dict[str, DiseaseEntity]    = {}

    # ── Đăng ký thực thể ──────────────────────────────────────────────────────

    def add_symptom(self, s: SymptomEntity):
        self.symptoms[s.id] = s

    def add_department(self, d: DepartmentEntity):
        self.departments[d.id] = d

    def add_doctor(self, doc: DoctorEntity):
        self.doctors[doc.id] = doc

    def add_disease(self, dis: DiseaseEntity):
        self.diseases[dis.id] = dis

    # ── Quan hệ is-a (phân cấp chuyên khoa) ──────────────────────────────────

    DEPT_HIERARCHY = {
        # Chuyên khoa cha → [chuyên khoa con]
        "noi_khoa": ["tim_mach", "ho_hap", "tieu_hoa", "noi_tiet", "than_kinh"],
        "ngoai_khoa": ["chinh_hinh", "than_kinh_ngoai"],
    }

    def get_parent_dept(self, dept_id: str) -> Optional[str]:
        for parent, children in self.DEPT_HIERARCHY.items():
            if dept_id in children:
                return parent
        return None

    # ── Truy vấn ──────────────────────────────────────────────────────────────

    def get_doctors_by_dept(self, dept_id: str) -> List[DoctorEntity]:
        return [d for d in self.doctors.values() if d.department_id == dept_id]

    def get_dept_symptoms(self, dept_id: str) -> List[SymptomEntity]:
        dept = self.departments.get(dept_id)
        if not dept:
            return []
        return [self.symptoms[sid] for sid in dept.treats_symptoms if sid in self.symptoms]

    def match_symptoms_text(self, text: str) -> List[SymptomEntity]:
        """Nhận dạng triệu chứng từ văn bản tự do (keyword matching)."""
        text_lower = text.lower()
        matched = []
        seen = set()
        for sym in self.symptoms.values():
            for kw in sym.keywords + sym.aliases:
                if kw.lower() in text_lower and sym.id not in seen:
                    matched.append(sym)
                    seen.add(sym.id)
                    break
        return matched
