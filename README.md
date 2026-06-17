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

Dưới đây là các bước chi tiết để setup và chạy dự án sau khi bạn clone source code từ Github về.

### Bước 1: Thiết lập Firebase (Xác thực & Lưu trữ hồ sơ người dùng)
1. Truy cập [Firebase Console](https://console.firebase.google.com/) và tạo một dự án mới.
2. Bật tính năng **Authentication** (Hỗ trợ Đăng nhập bằng Email/Password và Số điện thoại).
3. Bật tính năng **Firestore Database** (chọn chế độ Start in Test Mode). 
   *(Lưu ý: Không cần import dữ liệu mồi, code Android đã được thiết lập để tự động tạo Collection và cấu trúc bảng trên Firestore khi có người dùng mới đăng ký).*
4. Thêm ứng dụng Android vào Firebase project, tải file `google-services.json` và chép đè vào thư mục `DACS3-HEALTHMATE_VNH-NDVB/app/` trong source code.

### Bước 2: Thiết lập Supabase (Cơ sở dữ liệu chính & Trí tuệ nhân tạo)
1. Truy cập [Supabase](https://supabase.com/) và tạo dự án mới.
2. Vào mục **SQL Editor**, tạo một New Query và copy toàn bộ nội dung của file `.sql` (file database đính kèm trong repo) dán vào, sau đó ấn **Run**. Thao tác này sẽ tự động khởi tạo toàn bộ các bảng, dữ liệu chuyên khoa, bác sĩ và các luật tư vấn AI.
3. Vào **Project Settings -> API** để lấy `Project URL` và `anon public key`.
4. Mở Android Studio, tìm đến file `app/src/main/java/com/example/dacs3_healthmate/SupabaseClient.kt` và thay thế bằng URL, Key của bạn.

### Bước 3: Khởi chạy AI Backend (Python FastAPI)
Hệ thống AI xử lý ngôn ngữ tự nhiên và suy luận được viết bằng Python. Bạn cần chạy nó song song với app.
1. Mở terminal tại thư mục gốc của dự án.
2. (Tùy chọn) Tạo và kích hoạt môi trường ảo (venv).
3. Cài đặt các thư viện Python:
   ```bash
   pip install -r requirements.txt
   ```
4. Đảm bảo cấu hình URL/Key của Supabase trong Backend Python (file `.env` hoặc trực tiếp trong file cấu hình) khớp với dự án của bạn.
5. Khởi chạy Server:
   ```bash
   uvicorn main:app --reload --host 0.0.0.0 --port 8000
   ```
   *Server sẽ lắng nghe tại `http://localhost:8000`.*

### Bước 4: Biên dịch và chạy ứng dụng Android
1. Mở Android Studio, chọn **Open an existing project** và trỏ đường dẫn tới thư mục `DACS3-HEALTHMATE_VNH-NDVB`.
2. Đợi Gradle đồng bộ (Sync) hoàn tất.
3. **Lưu ý cấu hình IP kết nối tới Backend API:**
   - Nếu chạy app trên **Máy ảo (Emulator)**: Sử dụng IP `http://10.0.2.2:8000` thay cho localhost để gọi tới backend.
   - Nếu chạy app trên **Máy thật**: Phải đảm bảo điện thoại và máy tính kết nối chung mạng Wi-Fi. Bạn cần đổi URL gọi API thành địa chỉ IPv4 LAN của máy tính đang chạy Python (ví dụ: `http://192.168.1.x:8000`).
4. Nhấn **Run (Shift + F10)** để cài đặt app lên thiết bị và trải nghiệm.

