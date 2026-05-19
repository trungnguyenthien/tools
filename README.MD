# 🛠️ Bộ Công Cụ Tiện Ích Trình Duyệt (Web Utilities)

Chào mừng bạn đến với kho lưu trữ các công cụ tiện ích nhỏ gọn, chạy trực tiếp hoàn toàn trên trình duyệt của bạn (Client-side) mà không cần cài đặt hay gửi dữ liệu lên server, đảm bảo tính riêng tư và tốc độ xử lý tối đa.

---

## 🔒 Cam kết Bảo mật & Riêng tư
- **Xử lý 100% trên trình duyệt:** Mọi hoạt động đọc, mã hóa và chuyển đổi tệp tin đều diễn ra cục bộ trực tiếp trên trình duyệt của bạn (Client-side).
- **Không lưu trữ & Không chia sẻ:** Cam kết tuyệt đối không lưu trữ, không thu thập và không gửi bất kỳ dữ liệu hay tệp tin nào của bạn lên máy chủ hoặc cho bên thứ ba. Quyền riêng tư của bạn được bảo vệ tuyệt đối.

---

## 📌 Danh sách công cụ

### 1. 📂 [Base64 Encoder](./base64-encoder.html)
*Công cụ mã hóa tệp tin sang chuỗi Base64 cực kỳ nhanh chóng và tiện lợi.*
- **Tính năng nổi bật:**
  - **Đa dạng định dạng:** Hỗ trợ kéo-thả hoặc chọn đồng thời nhiều tệp tin bất kỳ (văn bản thường, hình ảnh, âm thanh, video, PDF, zip...).
  - **Xem & Sao chép nhanh:** Cho phép xem trực tiếp đoạn mã Base64 (thu gọn/mở rộng) và sao chép nhanh vào Clipboard chỉ với một nút bấm.
  - **Thống kê chi tiết:** Hiển thị độ dài chuỗi Base64, dung lượng tệp gốc và tỷ lệ phình dung lượng thực tế.
  - **Chạy offline:** Thực hiện mã hóa hoàn toàn trên trình duyệt bằng `FileReader`, bảo mật tuyệt đối dữ liệu cá nhân.

---

### 2. 📚 [Markdown → EPUB Converter](./md-to-epub.html)
*Công cụ chuyển đổi tài liệu Markdown sang định dạng sách điện tử EPUB tiêu chuẩn.*
- **Tính năng nổi bật:**
  - **Chuyển đổi hàng loạt (Batch):** Hỗ trợ kéo-thả nhiều file Markdown (`.md`, `.markdown`, `.txt`) và tiến hành chuyển đổi độc lập hoặc hàng loạt.
  - **Nhúng ảnh thông minh:** Tự động phát hiện các liên kết ảnh trong file (Markdown & HTML img), tự động tải ảnh qua hệ thống CORS proxy dự phòng nhiều lớp (`corsproxy.io`, `allorigins.win`, `codetabs.com`) và nhúng trực tiếp ảnh dưới dạng Base64 vào file EPUB.
  - **Đúng chuẩn EPUB 3.0:** Tự động sinh cấu trúc chuẩn gồm thư mục chứa ảnh, file cấu trúc tệp tin (`content.opf`), bảng mục lục (`nav.xhtml`), nội dung sách (`content.xhtml`) được định dạng CSS tối ưu cho việc đọc.
  - **Nhật ký chi tiết (Log):** Cung cấp giao diện log trực quan theo dõi chi tiết từng tiến trình tải ảnh và chuyển đổi tệp tin.

---

## 🚀 Cách sử dụng
1. Tải toàn bộ mã nguồn về máy hoặc truy cập trực tiếp qua GitHub Pages.
2. Click đúp chuột vào bất kỳ file `.html` nào (`base64-encoder.html` hoặc `md-to-epub.html`) để mở trên trình duyệt.
3. Không cần cài đặt môi trường hay máy chủ bổ sung!
