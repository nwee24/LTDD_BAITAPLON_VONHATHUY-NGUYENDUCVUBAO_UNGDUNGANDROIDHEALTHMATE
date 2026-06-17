# Ứng dụng Android Quản lý Phòng khám& Hỗ trợ đặt lịch khám thông minh HealthMate

## Giới thiệu
HealthMate là hệ thống tư vấn sức khỏe thông minh gồm 2 thành phần chính:
1. **Backend AI Consultation (Python - FastAPI)**: Hệ thống trí tuệ nhân tạo sử dụng biểu diễn tri thức (Knowledge Representation) thông qua **Production Rules** (Luật suy diễn IF-THEN) và **Semantic Graph** (Đồ thị ngữ nghĩa) để phân tích triệu chứng bằng ngôn ngữ tự nhiên, từ đó đưa ra chẩn đoán, đề xuất chuyên khoa và bác sĩ phù hợp nhất.
2. **Android Application (Kotlin)**: Ứng dụng di động dành cho người bệnh và bác sĩ. Mã nguồn nằm trong thư mục `DACS3-HEALTHMATE_VNH-NDVB/`.

## Cấu trúc thư mục
- `main.py`: Entry point của FastAPI backend. Chứa các API endpoints chính.
- `knowledge_base/`: Chứa bộ não suy luận AI:
  - `symptom_extractor.py`: Trích xuất triệu chứng từ văn bản tự nhiên.
  - `production_rules.py`: Các luật suy diễn (Forward-chaining inference).
  - `semantic_graph.py`: Xử lý tìm kiếm ngữ nghĩa, quan hệ triệu chứng - khoa bệnh.
  - `supabase_loader.py`: Đồng bộ dữ liệu chuyên khoa, bác sĩ và luật AI động từ Supabase.
- `requirements.txt`: Chứa danh sách các thư viện Python.
- `patch_main.py`: Script hỗ trợ cập nhật thêm các luật AI mới.
- `DACS3-HEALTHMATE_VNH-NDVB/`: Source code của ứng dụng Android.

---

## Hướng dẫn cài đặt và sử dụng

### Phần 1: Khởi chạy AI Backend (FastAPI)

**1. Yêu cầu hệ thống:**
- Python 3.8 trở lên.

**2. Cài đặt thư viện:**
Mở terminal/command prompt tại thư mục gốc của dự án (`c:/Users/ACER/OneDrive/Desktop/full`):
```bash
# (Tùy chọn) Tạo môi trường ảo
python -m venv .venv

# Kích hoạt môi trường ảo
# Trên Windows:
.venv\Scripts\activate
# Trên macOS/Linux:
source .venv/bin/activate

# Cài đặt các gói phụ thuộc
pip install -r requirements.txt
```

**3. Chạy Server:**
```bash
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```
Server sẽ chạy tại `http://localhost:8000`.
Bạn có thể truy cập `http://localhost:8000/docs` để xem tài liệu tương tác (Swagger UI) và thử nghiệm trực tiếp các API.

### Phần 2: Thiết lập Cơ sở dữ liệu (Supabase)

Backend giao tiếp với cơ sở dữ liệu trên Supabase để lấy thông tin bác sĩ, chuyên khoa và luật AI.
- Chỉnh sửa URL và API Key của Supabase nếu cần thiết.

### Phần 3: Chạy ứng dụng Android

**1. Yêu cầu hệ thống:**
- Android Studio bản mới nhất.
- JDK 17 (hoặc tương đương).

**2. Biên dịch và Chạy:**
- Mở Android Studio.
- Chọn **Open an existing project** và trỏ đường dẫn tới thư mục `DACS3-HEALTHMATE_VNH-NDVB`.
- Chờ cho Gradle đồng bộ hoàn tất (Sync).
- Đảm bảo thiết bị máy ảo (Emulator) hoặc điện thoại thật (cắm cáp USB và bật Debugging) đã sẵn sàng.
- Nhấn **Run (Shift + F10)**.

> **Lưu ý kết nối API**: Nếu ứng dụng Android chạy trên máy ảo, và backend API đang chạy local tại port 8000, ứng dụng cần gọi tới `http://10.0.2.2:8000` (thay vì localhost) để kết nối thành công tới backend. Nếu dùng máy thật, bạn cần sử dụng địa chỉ IPv4 LAN của máy tính đang chạy uvicorn (ví dụ `http://192.168.1.x:8000`).

---

