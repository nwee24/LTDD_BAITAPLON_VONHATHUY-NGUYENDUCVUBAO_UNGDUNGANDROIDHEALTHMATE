# -*- coding: utf-8 -*-
"""
SYMPTOM EXTRACTOR — Nhận dạng triệu chứng từ văn bản tự nhiên (mở rộng)
Hỗ trợ 300+ cách diễn đạt khác nhau bằng tiếng Việt thông thường.
"""

import re
import logging
from typing import List, Tuple

logger = logging.getLogger(__name__)

SYMPTOM_KEYWORD_MAP: List[Tuple[List[str], str]] = [

    # ── ĐẦU / THẦN KINH ─────────────────────────────────────────────────────
    (["đau đầu", "nhức đầu", "đầu đau", "đau nửa đầu", "migraine", "đầu nhức",
      "đau đầu dữ dội", "nhức đầu nhiều", "đau đầu liên tục", "đầu đau quá",
      "đau đầu cả ngày", "thấy đầu nặng", "đầu nặng nề", "đầu váng"], "dau_dau"),

    (["chóng mặt", "hoa mắt", "xây xẩm", "choáng váng", "mất thăng bằng",
      "xây xẩm mặt mày", "quay cuồng", "đầu quay", "nhìn mọi thứ quay",
      "chóng mặt khi đứng lên", "chóng mặt lúc ngồi dậy", "váng đầu",
      "đầu óc quay cuồng", "hay bị chóng mặt"], "chong_mat"),

    (["buồn nôn", "buồn ói", "muốn nôn", "nausea", "cảm giác buồn nôn",
      "hay buồn nôn", "buồn nôn sau ăn", "bụng muốn ói", "thấy buồn nôn"], "buon_non"),

    (["nôn", "ói", "nôn mửa", "ói mửa", "nôn ra", "nôn nhiều lần",
      "ói xong", "nôn xong mới thấy đỡ", "bị nôn"], "non"),

    (["mất ngủ", "khó ngủ", "không ngủ được", "ngủ ít", "trằn trọc",
      "ngủ không sâu", "thức giấc giữa đêm", "hay thức đêm", "không ngủ được",
      "nằm mãi không ngủ", "ngủ không ngon", "buổi tối không ngủ",
      "trằn trọc cả đêm", "mất ngủ mãi", "khó đi vào giấc ngủ"], "mat_ngu"),

    (["lo âu", "lo lắng", "bồn chồn", "hồi hộp lo", "anxiety", "hay lo",
      "lo sợ", "tâm trạng bất an", "cảm thấy sợ", "sợ hãi vô cớ",
      "lo nhiều", "tâm lý lo lắng", "stress nặng", "căng thẳng kéo dài"], "lo_au"),

    (["trầm cảm", "buồn bã kéo dài", "mất hứng thú", "chán nản",
      "không muốn làm gì", "sống không có ý nghĩa", "hay khóc",
      "không vui được", "cảm thấy vô vọng", "không có động lực",
      "tâm trạng u uất", "buồn không lý do"], "tram_cam"),

    (["tê bì", "tê tay", "tê chân", "tê buốt", "kiến bò", "tê liệt nhẹ",
      "tay bị tê", "chân bị tê", "tê ran", "cảm giác tê", "bàn tay tê",
      "ngón tay tê", "tê cả tay lẫn chân"], "te_bi"),

    (["yếu liệt", "liệt", "yếu tay", "yếu chân", "không cử động được",
      "chân tay không có sức", "tay chân bị yếu", "không nhấc được chân",
      "sức cơ yếu", "không bước đi được"], "yeu_liet"),

    (["co giật", "giật", "động kinh", "lên cơn", "cơn giật",
      "co cứng người", "giật tay chân", "ngất đột ngột"], "co_giat"),

    (["nhạy cảm ánh sáng", "sợ ánh sáng", "chói mắt", "nhìn ánh sáng thấy đau",
      "ánh sáng làm đau đầu", "không chịu được ánh sáng"], "nhay_cam_anh_sang"),

    # ── TIM MẠCH ────────────────────────────────────────────────────────────
    (["đau ngực", "tức ngực", "nặng ngực", "ép ngực", "đau tim",
      "ngực đau", "cảm giác bị đè nặng ở ngực", "đau lan ra vai",
      "đau ngực khi đi bộ", "đau ngực gắng sức", "thắt ngực",
      "đau ở vùng tim", "ngực tức", "ngực thắt lại"], "dau_nguc"),

    (["khó thở", "thở khó", "hụt hơi", "thở nông", "không thở được",
      "thở không ra hơi", "hụt hơi khi gắng sức", "thở mệt",
      "leo cầu thang khó thở", "ngủ hay tỉnh giấc vì khó thở",
      "thở yếu", "cảm thấy thiếu không khí", "thở không đủ"], "kho_tho"),

    (["tim đập nhanh", "nhịp tim nhanh", "tim đập loạn", "loạn nhịp",
      "tim đập bất thường", "tim hồi hộp", "tim đập mạnh",
      "cảm thấy tim đập", "nhịp tim không đều", "đánh trống ngực"], "tim_dap_nhanh"),

    (["hồi hộp", "đánh trống ngực", "tim thình thịch",
      "cảm giác hồi hộp", "bồn chồn trong lồng ngực"], "hoi_hop"),

    (["phù chân", "sưng chân", "chân phù", "chân sưng to",
      "hai chân sưng", "mắt cá sưng", "bàn chân sưng"], "phu_chan"),

    (["huyết áp cao", "cao huyết áp", "tăng huyết áp", "huyết áp tăng",
      "đo huyết áp cao", "máu áp cao", "HA cao"], "huyet_ap_cao"),

    # ── TỔNG QUÁT ────────────────────────────────────────────────────────────
    (["mệt mỏi", "mệt", "kiệt sức", "uể oải", "mệt lả", "người mệt",
      "cơ thể mệt", "hay mệt", "mệt suốt ngày", "mệt không rõ nguyên nhân",
      "không có sức", "mệt cả ngày", "dậy mà vẫn mệt",
      "cảm thấy kiệt sức", "người không có lực", "mệt quá"], "met_moi"),

    (["sốt", "bị sốt", "người nóng", "sốt nhẹ", "lên cơn sốt",
      "nóng người", "cảm thấy nóng", "đo nhiệt độ cao", "thân nhiệt cao",
      "người ấm nóng", "sốt mấy ngày"], "sot"),

    (["sốt cao", "sốt trên 38", "sốt 39", "sốt 40", "sốt quá cao",
      "sốt rất cao", "sốt không hạ", "sốt mãi không khỏi"], "sot_cao"),

    (["ớn lạnh", "rét run", "lạnh run", "run rẩy", "người lạnh rồi nóng",
      "sốt kèm rét", "nóng lạnh xen kẽ"], "on_lanh"),

    (["chán ăn", "không muốn ăn", "mất cảm giác ngon", "ăn không ngon",
      "không thèm ăn", "ăn ít", "bỏ bữa", "không muốn ăn gì"], "chan_an"),

    (["sụt cân", "giảm cân không rõ lý do", "sụt cân nhanh",
      "gầy đi trông thấy", "sụt mấy ký"], "sut_can"),

    # ── HÔ HẤP / TAI MŨI HỌNG ───────────────────────────────────────────────
    (["ho kéo dài", "ho lâu", "ho mãn tính", "ho dai dẳng",
      "ho hoài không khỏi", "ho cả tuần", "ho mãi", "ho nhiều ngày"], "ho_keo_dai"),

    (["có đờm", "đờm", "khạc đờm", "ho có đờm", "đờm xanh", "đờm vàng",
      "khạc ra đờm", "cổ có đờm", "nhiều đờm"], "co_dom"),

    (["thở khò khè", "khò khè", "thở rít", "rít", "tiếng thở khò khè",
      "thở có tiếng rít"], "tho_kho_khe"),

    (["ho ra máu", "khạc ra máu", "ho máu", "đàm có máu"], "ho_ra_mau"),

    (["sổ mũi", "chảy mũi", "nghẹt mũi", "ngạt mũi", "mũi bị nghẹt",
      "mũi chảy nước", "nước mũi", "mũi không thở được",
      "hay bị nghẹt mũi", "mũi tịt"], "so_mui"),

    (["hắt hơi", "hắt xì", "hắt hơi liên tục", "hắt hơi nhiều",
      "hắt xì liên tục", "hắt hơi cả ngày"], "hat_hoi"),

    (["đau họng", "đau cổ họng", "rát họng", "viêm họng", "họng đau",
      "nuốt đau", "nuốt khó", "cổ họng đau", "họng rát",
      "đau khi nuốt", "cảm giác vướng cổ họng", "sưng amidan"], "dau_hong"),

    (["ù tai", "tai ù", "nghe kém", "điếc một bên", "tiếng ù trong tai",
      "tai kêu", "không nghe rõ", "mất thính lực"], "u_tai"),

    (["chảy máu mũi", "chảy máu cam", "hay chảy máu mũi",
      "máu cam", "mũi chảy máu"], "chay_mau_mui"),

    # ── TIÊU HÓA ────────────────────────────────────────────────────────────
    (["đau bụng", "đau dạ dày", "đau vùng bụng", "bụng đau",
      "bụng quặn", "đau bụng dữ dội", "đau vùng thượng vị",
      "đau bụng âm ỉ", "bụng đau liên tục", "hay đau bụng",
      "đau bụng sau khi ăn", "đau bụng về đêm",
      "bụng khó chịu", "bụng quặn đau", "đau bụng quanh rốn"], "dau_bung"),

    (["đau thượng vị", "đau dạ dày trên", "vùng bụng trên đau",
      "đau vùng trên rốn", "thượng vị đau"], "dau_thuong_vi"),

    (["ợ chua", "trào ngược", "ợ nóng", "heartburn", "ợ hơi",
      "hay ợ chua", "dạ dày trào ngược", "axit dạ dày trào lên",
      "cảm giác chua trong miệng", "bụng hay ợ"], "o_chua"),

    (["tiêu chảy", "đi lỏng", "phân lỏng", "đi ngoài nhiều lần",
      "hay đi lỏng", "tiêu chảy nhiều lần", "đi cầu nhiều",
      "phân không thành khuôn", "đau bụng đi lỏng"], "tieu_chay"),

    (["táo bón", "khó đi cầu", "không đi cầu được", "phân cứng",
      "mấy ngày không đi cầu", "bị táo", "đi cầu khó"], "tao_bon"),

    (["đau quặn bụng", "quặn bụng", "đau co thắt", "bụng co thắt",
      "co thắt ruột", "đau quặn từng cơn"], "dau_quan_bung"),

    (["vàng da", "da vàng", "da ngả vàng", "da hơi vàng",
      "bị vàng da", "da màu vàng"], "vang_da"),

    (["vàng mắt", "mắt vàng", "kết mạc vàng", "lòng trắng mắt vàng",
      "mắt bị vàng"], "vang_mat"),

    (["đi ngoài ra máu", "phân có máu", "đi cầu ra máu",
      "máu theo phân", "hậu môn chảy máu"], "di_ngoai_ra_mau"),

    (["chướng bụng", "bụng đầy hơi", "bụng trướng", "đầy hơi",
      "hay bị đầy bụng", "bụng phình to", "ăn xong bụng to"], "chuong_bung"),

    # ── CƠ XƯƠNG KHỚP ──────────────────────────────────────────────────────
    (["đau lưng", "đau cột sống", "đau thắt lưng", "đau lưng dưới",
      "lưng đau", "đau lưng âm ỉ", "đau lưng khi ngồi lâu",
      "đau lưng khi làm việc", "đau vùng thắt lưng",
      "đau cột sống thắt lưng", "lưng bị đau", "hay đau lưng",
      "đau từ lưng xuống chân"], "dau_lung"),

    (["cứng khớp", "khớp cứng", "cứng buổi sáng", "khó cử động khớp",
      "sáng ngủ dậy khớp cứng", "khớp bị cứng"], "cung_khop"),

    (["sưng khớp", "khớp sưng", "viêm khớp", "khớp bị sưng đỏ",
      "khớp sưng đau", "khớp sưng lên", "bị sưng đỏ", "sưng đỏ",
      "gối sưng", "gối bị sưng", "đầu gối sưng đỏ"], "sung_khop"),

    (["đau khớp gối", "đau đầu gối", "gối đau", "gối bị đau",
      "đầu gối đau nhức", "đau ở khớp gối"], "dau_khop_goi"),

    (["đau cổ", "đau vùng cổ", "cứng cổ", "vẹo cổ", "cổ đau",
      "cổ bị cứng", "không quay cổ được", "đau vùng gáy", "đau gáy"], "dau_co"),

    (["đau vai", "vai đau", "đau khớp vai", "vai bị đau",
      "đau bả vai", "đau vai lan xuống tay"], "dau_vai"),

    (["đau khớp ngón tay", "ngón tay đau", "ngón tay sưng",
      "khớp ngón sưng đỏ", "đau các khớp nhỏ"], "dau_khop_nho"),

    # ── NỘI TIẾT ────────────────────────────────────────────────────────────
    (["khát nước nhiều", "uống nhiều nước", "miệng khô", "hay khát",
      "khát không dứt", "khát nước liên tục", "uống nhiều vẫn khát",
      "miệng hay khô"], "khat_nuoc"),

    (["tiểu nhiều", "đi tiểu nhiều", "tiểu đêm nhiều", "tiểu liên tục",
      "đi tiểu liên tục", "tiểu đêm", "hay đi tiểu ban đêm",
      "tiểu mấy lần một đêm"], "tieu_nhieu"),

    (["tăng cân", "béo phì", "tăng cân nhanh", "cân nặng tăng không rõ",
      "bỗng béo lên", "tăng cân bất thường"], "tang_can"),

    (["cảm thấy lạnh", "lạnh tay chân", "sợ lạnh", "hay lạnh",
      "tay chân luôn lạnh", "không chịu được lạnh",
      "người lúc nào cũng lạnh"], "cam_thay_lanh"),

    (["ra mồ hôi nhiều", "đổ mồ hôi trộm", "mồ hôi nhiều ban đêm",
      "hay toát mồ hôi", "mồ hôi đêm", "vã mồ hôi lạnh"], "mo_hoi_nhieu"),

    # ── DA LIỄU ─────────────────────────────────────────────────────────────
    (["nổi mẩn", "phát ban", "nổi ban", "nổi mề đay", "dị ứng da",
      "nổi mẩn ngứa", "da nổi hạt", "nổi mụn nước", "nổi mẩn đỏ",
      "ban đỏ khắp người", "da nổi ban", "nổi mề đay khắp người",
      "hay bị dị ứng"], "noi_man"),

    (["ngứa", "ngứa da", "ngứa ran", "ngứa nhiều", "da ngứa",
      "ngứa khắp người", "ngứa không chịu được", "ngứa dữ dội",
      "hay bị ngứa", "ngứa toàn thân", "gãi hoài"], "ngua"),

    (["mụn trứng cá", "mụn", "mụn nhiều", "mụn viêm", "nhiều mụn",
      "mụn bọc", "da nổi mụn", "hay bị mụn", "mụn không hết"], "mun_trung_ca"),

    (["da nhờn", "da dầu", "tiết nhiều dầu", "da bóng nhờn",
      "mặt nhờn", "da nhiều dầu"], "da_nhon"),

    (["da khô", "da bong tróc", "da nứt nẻ", "da bị khô",
      "da thiếu ẩm", "da hay bong"], "da_kho"),

    (["rụng tóc", "tóc rụng nhiều", "hay rụng tóc", "tóc thưa dần",
      "đầu hói dần", "tóc rụng cả nắm"], "rung_toc"),

    # ── MẮT ─────────────────────────────────────────────────────────────────
    (["mờ mắt", "nhìn mờ", "nhìn không rõ", "thị lực giảm",
      "mắt mờ đi", "mờ khi đọc sách", "nhìn xa không rõ",
      "đeo kính vẫn mờ", "mắt bị mờ"], "mo_mat"),

    (["đau mắt", "mắt đau", "nhức mắt", "mắt nhức",
      "đau hốc mắt", "nhức hốc mắt"], "dau_mat"),

    (["đỏ mắt", "mắt đỏ", "viêm kết mạc", "mắt bị đỏ",
      "lòng trắng đỏ", "mắt đỏ ngầu"], "do_mat"),

    (["chảy nước mắt", "nước mắt chảy nhiều", "mắt hay chảy nước",
      "mắt cộm", "cộm mắt", "có dị vật trong mắt"], "chay_nuoc_mat"),

    # ── TIẾT NIỆU ───────────────────────────────────────────────────────────
    (["tiểu buốt", "đau khi tiểu", "tiểu khó", "tiểu rát",
      "tiểu ra buốt", "đi tiểu buốt", "hay bị tiểu buốt",
      "tiểu xong vẫn còn buốt", "cảm giác buốt khi đi tiểu"], "tieu_buot"),

    (["nước tiểu đục", "tiểu đục", "nước tiểu có máu", "tiểu ra máu",
      "nước tiểu màu đỏ", "nước tiểu có mùi hôi",
      "nước tiểu đổi màu"], "nuoc_tieu_duc"),

    (["đau vùng thận", "đau hông lưng", "đau hông", "đau vùng hông",
      "sỏi thận", "đau thận", "đau lan từ lưng xuống bẹn"], "dau_than"),

    # ── SẢN PHỤ KHOA ────────────────────────────────────────────────────────
    (["đau bụng dưới", "đau vùng chậu", "đau bụng kinh",
      "vùng bụng dưới đau", "đau bụng dưới âm ỉ",
      "đau vùng bụng dưới"], "dau_bung_duoi"),

    (["kinh nguyệt bất thường", "rối loạn kinh nguyệt", "trễ kinh",
      "kinh không đều", "kinh ra nhiều", "kinh ra ít",
      "không có kinh", "hay bị trễ kinh", "kinh nguyệt không đều",
      "hành kinh đau"], "kinh_nguyet_bat_thuong"),

    (["ra khí hư", "khí hư bất thường", "huyết trắng",
      "khí hư có mùi", "tiết dịch âm đạo bất thường"], "khi_hu"),

    # ── NHI KHOA ────────────────────────────────────────────────────────────
    (["phát ban", "ban đỏ", "nổi ban đỏ", "ban đỏ khắp người",
      "da nổi đốm đỏ", "nổi hồng ban"], "phat_ban"),

    (["quấy khóc", "khóc liên tục", "trẻ quấy", "bé khóc hoài",
      "trẻ hay quấy", "bé khóc không dứt", "quấy đêm"], "quay_khoc"),

    (["trẻ biếng ăn", "bé không ăn", "trẻ không chịu ăn",
      "biếng ăn", "trẻ bỏ ăn"], "tre_bieng_an"),

    # ── NGOẠI KHOA / CHẤN THƯƠNG ────────────────────────────────────────────
    (["đau bụng cấp", "đau bụng dữ dội đột ngột", "đau bụng không chịu được",
      "bụng cứng", "bụng co cứng", "nghi ruột thừa", "đau hố chậu phải"], "dau_bung_cap"),

    (["chấn thương", "té ngã", "va đập", "gãy xương", "bong gân",
      "bị đánh", "tai nạn", "trật khớp"], "chan_thuong"),

    (["vết thương", "vết loét", "lở loét", "không lành",
      "vết thương lâu lành", "mưng mủ", "chảy mủ"], "vet_thuong"),
]


def extract_symptom_ids(text: str) -> List[str]:
    """
    Nhận dạng symptom_id từ văn bản tự nhiên.
    Sử dụng keyword matching case-insensitive.
    """
    text_lower = text.lower().strip()
    # Chuẩn hóa: bỏ dấu câu thừa
    text_lower = re.sub(r'[,\.!?;]+', ' ', text_lower)

    found: List[str] = []
    seen = set()

    for keywords, symptom_id in SYMPTOM_KEYWORD_MAP:
        for kw in keywords:
            if kw in text_lower and symptom_id not in seen:
                found.append(symptom_id)
                seen.add(symptom_id)
                break

    return found


def describe_extracted(symptom_ids: List[str]) -> str:
    """Tóm tắt các triệu chứng đã nhận dạng."""
    name_map = {}
    for kws, sid in SYMPTOM_KEYWORD_MAP:
        if sid not in name_map:
            name_map[sid] = kws[0].capitalize()

    names = [name_map.get(sid, sid) for sid in symptom_ids]
    if not names:
        return "Không nhận dạng được triệu chứng cụ thể."
    return "Triệu chứng nhận dạng: " + ", ".join(names)


def load_dynamic_keywords(db_rules: List[dict]):
    """Gộp các từ khóa từ CSDL Supabase vào SYMPTOM_KEYWORD_MAP."""
    added_count = 0
    existing_map = {}
    for kw_list, sid in SYMPTOM_KEYWORD_MAP:
        existing_map[sid] = kw_list

    for r in db_rules:
        sid = r.get("symptom_id")
        kws_str = r.get("symptom_keywords")
        if not sid or not kws_str:
            continue

        new_kws = [k.strip().lower() for k in kws_str.split(",") if k.strip()]
        if not new_kws:
            continue

        if sid in existing_map:
            target_list = existing_map[sid]
            for kw in new_kws:
                if kw not in target_list:
                    target_list.append(kw)
                    added_count += 1
        else:
            SYMPTOM_KEYWORD_MAP.append((new_kws, sid))
            existing_map[sid] = new_kws
            added_count += len(new_kws)

    logger.info("✅ Symptom keywords expanded from DB: added %d keywords", added_count)
