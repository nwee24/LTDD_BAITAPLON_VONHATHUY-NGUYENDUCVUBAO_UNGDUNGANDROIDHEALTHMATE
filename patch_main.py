# -*- coding: utf-8 -*-
"""Patch: 1) thêm keywords còn thiếu vào extractor, 2) thêm rules mới."""

# ── Patch production_rules.py: thêm rule cho sut_can, mo_hoi_nhieu, chan_thuong ──
with open("knowledge_base/production_rules.py", "r", encoding="utf-8") as f:
    rules = f.read()

NEW_RULES = '''        ProductionRule(
            id="R120",
            name="Sụt cân không rõ lý do → Nội tổng quát",
            conditions=["sut_can"],
            department="Khoa Nội tổng quát",
            confidence=70, priority=2,
            advice="• Xét nghiệm máu tổng quát\\n• Kiểm tra tuyến giáp, đường huyết\\n• Siêu âm ổ bụng"
        ),
        ProductionRule(
            id="R121",
            name="Mồ hôi đêm + mệt mỏi → Nội tổng quát",
            conditions=["mo_hoi_nhieu", "met_moi"],
            department="Khoa Nội tổng quát",
            confidence=72, priority=2,
            advice="• Xét nghiệm công thức máu\\n• Kiểm tra tuyến giáp\\n• Đo đường huyết lúc đói"
        ),
        ProductionRule(
            id="R122",
            name="Sưng khớp gối → Cơ Xương Khớp",
            conditions=["sung_khop"],
            department="Khoa Cơ Xương Khớp",
            confidence=75, priority=3,
            advice="• Chườm đá 15 phút x 3 lần/ngày\\n• Hạn chế đứng lâu\\n• Siêu âm khớp\\n• Dùng thuốc kháng viêm theo chỉ định"
        ),
        ProductionRule(
            id="R123",
            name="Chấn thương / té ngã → Ngoại khoa",
            conditions=["chan_thuong"],
            department="Khoa Ngoại",
            confidence=88, priority=4,
            advice="• Đến phòng cấp cứu ngay\\n• Chụp X-quang vùng bị thương\\n• Không tự nắn khớp"
        ),
        ProductionRule(
            id="R124",
            name="Đau bụng cấp → Ngoại khoa",
            conditions=["dau_bung_cap"],
            department="Khoa Ngoại",
            confidence=90, priority=5,
            advice="• GỌI CẤP CỨU NGAY (115)\\n• Không ăn uống\\n• Không uống thuốc giảm đau trước khi khám"
        ),
        ProductionRule(
            id="R125",
            name="Ù tai / Nghe kém → Tai Mũi Họng",
            conditions=["u_tai"],
            department="Khoa Tai Mũi Họng",
            confidence=82, priority=3,
            advice="• Đo thính lực\\n• Tránh tiếng ồn lớn\\n• Không tự nhỏ thuốc tai\\n• Đến khám sớm"
        ),
        ProductionRule(
            id="R126",
            name="Đỏ mắt + đau mắt → Mắt",
            conditions=["do_mat", "dau_mat"],
            department="Khoa Mắt",
            confidence=85, priority=3,
            advice="• Không dụi mắt\\n• Nhỏ nước mắt nhân tạo\\n• Đến khám nhãn khoa ngay"
        ),
        ProductionRule(
            id="R127",
            name="Khí hư bất thường → Sản Phụ khoa",
            conditions=["khi_hu"],
            department="Khoa Sản Phụ khoa",
            confidence=80, priority=3,
            advice="• Giữ vệ sinh vùng kín\\n• Không tự dùng thuốc đặt\\n• Xét nghiệm dịch âm đạo"
        ),
        ProductionRule(
            id="R128",
            name="Sốt + quấy khóc → Nhi khoa",
            conditions=["sot", "quay_khoc"],
            department="Khoa Nhi",
            confidence=85, priority=4,
            advice="• Hạ sốt bằng paracetamol đúng liều\\n• Chườm ấm\\n• Bổ sung nước điện giải\\n• Đến viện nếu sốt > 38.5°C"
        ),
'''

# Insert before last closing bracket of build_medical_rules
MARKER = "    ]\n"
idx = rules.rfind(MARKER)
if idx >= 0:
    rules = rules[:idx] + NEW_RULES + rules[idx:]
    with open("knowledge_base/production_rules.py", "w", encoding="utf-8") as f:
        f.write(rules)
    print("OK: 9 new rules added")
else:
    print("ERROR: marker not found in production_rules.py")

# ── Patch symptom_extractor.py: thêm keywords còn thiếu ──
with open("knowledge_base/symptom_extractor.py", "r", encoding="utf-8") as f:
    ext = f.read()

# Thêm "bị sưng" và "sưng đỏ" vào noi_man / sung_khop
old_sung = '(["sưng khớp", "khớp sưng", "viêm khớp", "khớp bị sưng đỏ",\n      "khớp sưng đau", "khớp sưng lên"], "sung_khop"),'
new_sung = '(["sưng khớp", "khớp sưng", "viêm khớp", "khớp bị sưng đỏ",\n      "khớp sưng đau", "khớp sưng lên", "bị sưng đỏ", "sưng đỏ",\n      "gối sưng", "gối bị sưng", "đầu gối sưng đỏ"], "sung_khop"),'

if old_sung in ext:
    ext = ext.replace(old_sung, new_sung, 1)
    with open("knowledge_base/symptom_extractor.py", "w", encoding="utf-8") as f:
        f.write(ext)
    print("OK: sung_khop keywords expanded")
else:
    print("WARN: sung_khop target not found")

print("Done!")
