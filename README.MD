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

### 3. 🔑 [Secret Key Generator](./secret-key-gen.html)
*Công cụ sinh mã khóa bảo mật ngẫu nhiên với độ an toàn mã hóa cao.*
- **Tính năng nổi bật:**
  - **Đa dạng định dạng:** Hỗ trợ sinh khóa Hexadecimal (API key, Salts), Base64 (JWT Secret, HMAC), Base64URL (URL-safe Session Token), UUID v4 (ID duy nhất), Mật khẩu gợi nhớ (Memorable Passphrase) và Mật khẩu phức tạp tùy chỉnh.
  - **An toàn tuyệt đối:** Sử dụng bộ sinh số ngẫu nhiên bảo mật của trình duyệt (`window.crypto.getRandomValues`), hoạt động 100% offline, cam kết không truyền dữ liệu ra ngoài.
  - **Tùy biến cao:** Cho phép tùy chỉnh độ dài khóa (Bytes hoặc ký tự), tùy chọn bộ ký tự sử dụng, số lượng từ gợi nhớ, ký tự phân cách và lọc bỏ các ký tự dễ nhầm lẫn (1, l, I, 0, O, o).
  - **Độ mạnh khóa:** Tích hợp bộ đánh giá độ mạnh của khóa (Entropy) trực quan dựa trên độ dài và loại thuật toán được chọn.

---

### 4. 🛡️ [Censor Secret](./sensor-secret.html)
*Công cụ lọc và che giấu các thông tin nhạy cảm trong văn bản trước khi chia sẻ.*
- **Tính năng nổi bật:**
  - **Nhận diện thông minh:** Tự động quét và phát hiện các loại dữ liệu nhạy cảm bao gồm: địa chỉ Email, số điện thoại, chuỗi Base64 dài, UUID v4/v1 và các định dạng API key / Hex Secret thông dụng.
  - **Hai chế độ ẩn danh:** 
    - *Thay thế Placeholder:* Ẩn hoàn toàn bằng các khóa đại diện mang tính nhất quán ngữ nghĩa (như `{EMAIL_1}`, `{UUID_2}`) để giữ nguyên mối liên kết giữa các biến khi gửi cho AI.
    - *Che giấu một phần:* Chỉ giữ lại 8 ký tự đầu tiên để đối chiếu và ẩn hoàn toàn phần còn lại (ví dụ: `abc123de...`).
  - **Bảng ánh xạ đối chiếu:** Tự động tạo bảng đối chiếu chi tiết giữa giá trị gốc và giá trị thay thế cục bộ để người dùng dễ dàng khôi phục khi cần thiết.
  - **Bảo mật tuyệt đối:** Lọc và xử lý hoàn toàn bằng biểu thức chính quy (Regex) cục bộ trên trình duyệt, cam kết không truyền bất kỳ thông tin nào ra bên ngoài.

---

## 🚀 Cách sử dụng
1. Tải toàn bộ mã nguồn về máy hoặc truy cập trực tiếp qua GitHub Pages.
2. Click đúp chuột vào bất kỳ file `.html` nào (`base64-encoder.html`, `md-to-epub.html`, `secret-key-gen.html` hoặc `sensor-secret.html`) để mở trên trình duyệt.
3. Không cần cài đặt môi trường hay máy chủ bổ sung!
