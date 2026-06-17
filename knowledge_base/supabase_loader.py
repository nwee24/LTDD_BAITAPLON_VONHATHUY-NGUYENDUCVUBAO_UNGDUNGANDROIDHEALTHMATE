"""
=============================================================================
 SUPABASE LOADER — Tải khoa và bác sĩ thật từ database
=============================================================================
 Kết nối Supabase REST API để lấy:
   - Bảng chuyen_khoa  → Department nodes trong Semantic Graph
   - Bảng bac_si       → Doctor nodes trong Semantic Graph

 Ánh xạ tên khoa DB → department_id dùng trong Production Rules
=============================================================================
"""

import httpx
import logging
from typing import List, Dict, Optional

logger = logging.getLogger(__name__)

SUPABASE_URL = "https://gqgrfvgzfnafnzsbiiid.supabase.co"
SUPABASE_KEY = "sb_publishable_6OlExV_Ud7ovoRKADXFY1Q_VqUFOQjv"

HEADERS = {
    "apikey": SUPABASE_KEY,
    "Authorization": f"Bearer {SUPABASE_KEY}",
    "Content-Type": "application/json",
}


def fetch_chuyen_khoa() -> List[Dict]:
    """Lấy tất cả chuyên khoa từ bảng chuyen_khoa."""
    try:
        r = httpx.get(
            f"{SUPABASE_URL}/rest/v1/chuyen_khoa",
            headers=HEADERS,
            params={"select": "ma_khoa,ten_khoa,mo_ta,anh_icon_url"},
            timeout=10,
        )
        r.raise_for_status()
        return r.json()
    except Exception as e:
        logger.error("fetch_chuyen_khoa error: %s", e)
        return []


def fetch_bac_si() -> List[Dict]:
    """Lấy tất cả bác sĩ kèm thông tin khoa từ bảng bac_si."""
    try:
        r = httpx.get(
            f"{SUPABASE_URL}/rest/v1/bac_si",
            headers=HEADERS,
            params={"select": "ma_bac_si,ho_ten,ma_khoa,hoc_vi,danh_gia,kinh_nghiem,chi_tiet_chuyen_mon,anh_chan_dung_url"},
            timeout=10,
        )
        r.raise_for_status()
        return r.json()
    except Exception as e:
        logger.error("fetch_bac_si error: %s", e)
        return []


# Ánh xạ tên khoa trong DB → dept_id dùng trong Production Rules & Semantic Graph
# (chuẩn hoá tên để khớp với tên trong rules)
KHOA_NAME_MAP: Dict[str, str] = {
    "nội khoa":          "Khoa Nội tổng quát",
    "ngoại khoa":        "Khoa Ngoại",
    "nhi khoa":          "Khoa Nhi",
    "sản phụ khoa":      "Khoa Sản Phụ khoa",
    "tai mũi họng":      "Khoa Tai Mũi Họng",
    "da liễu":           "Khoa Da liễu",
    "mắt":               "Khoa Mắt",
    "thần kinh":         "Khoa Thần kinh",
    "tim mạch":          "Khoa Tim mạch",
    "hô hấp":            "Khoa Hô hấp",
    "tiêu hóa":          "Khoa Tiêu hóa",
    "cơ xương khớp":     "Khoa Cơ Xương Khớp",
    "nội tiết":          "Khoa Nội tiết",
    "tiết niệu":         "Khoa Tiết niệu",
    "tâm thần":          "Khoa Tâm thần",
    "ung bướu":          "Khoa Ung bướu",
}


def normalize_dept_name(ten_khoa: str) -> str:
    """Chuẩn hoá tên khoa DB → tên dùng trong rules."""
    key = ten_khoa.lower().strip()
    # Khớp chính xác
    if key in KHOA_NAME_MAP:
        return KHOA_NAME_MAP[key]
    # Khớp gần đúng (tên khoa chứa từ khoá)
    for k, v in KHOA_NAME_MAP.items():
        if k in key or key in k:
            return v
    # Fallback: giữ nguyên với prefix "Khoa"
    return f"Khoa {ten_khoa}" if not ten_khoa.startswith("Khoa") else ten_khoa


def build_dept_id(ma_khoa: int) -> str:
    """Tạo dept_id dạng 'dept_<ma_khoa>' để dùng trong Semantic Graph."""
    return f"dept_db_{ma_khoa}"


def build_doctor_id(ma_bac_si: int) -> str:
    return f"dr_db_{ma_bac_si}"


def fetch_ai_training_rules() -> List[Dict]:
    """Lấy tất cả các quy tắc huấn luyện động từ bảng ai_training_rules trên Supabase."""
    try:
        r = httpx.get(
            f"{SUPABASE_URL}/rest/v1/ai_training_rules",
            headers=HEADERS,
            params={"select": "*"},
            timeout=10,
        )
        r.raise_for_status()
        return r.json()
    except Exception as e:
        logger.error("fetch_ai_training_rules error: %s", e)
        return []
