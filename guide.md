# 📖 Hướng Dẫn Phát Triển Công Cụ Mới (AI Tool Creation Guide)

Tài liệu này đóng vai trò là kim chỉ nam dành cho các tác nhân AI (AI Agents) hoặc nhà phát triển khi xây dựng, nâng cấp hoặc thiết kế các công cụ tiện ích web mới trong kho lưu trữ này. Hãy tuân thủ nghiêm ngặt các quy tắc dưới đây để đảm bảo tính nhất quán, bảo mật và thẩm mỹ của toàn bộ hệ thống.

---

## 1. 🔒 Nguyên Tắc Bảo Mật & Riêng Tư (100% Client-Side)

Đây là giá trị cốt lõi quan trọng nhất của toàn bộ kho công cụ. Người dùng tin tưởng kho lưu trữ này vì tính riêng tư tuyệt đối.

*   **Không Xử Lý Trên Máy Chủ:** Tất cả logic tính toán, phân tích cú pháp, mã hóa hoặc chuyển đổi dữ liệu **PHẢI** được thực hiện 100% cục bộ trên trình duyệt của người dùng (Client-side).
*   **Không Gửi Dữ Liệu Cho Bên Thứ Ba:** Tuyệt đối không tích hợp bất kỳ API, tracking script, analytics hoặc dịch vụ lưu trữ đám mây nào thu thập dữ liệu người dùng.
*   **Xử lý Tệp Tin Cục Bộ:** Sử dụng các API HTML5 tiêu chuẩn như `FileReader`, `Blob`, `URL.createObjectURL` để xử lý và tải xuống tệp tin thay vì tải tệp lên server.
*   **Sinh Số Ngẫu Nhiên An Toàn:** Đối với các tác vụ liên quan đến mật mã hoặc sinh khóa ngẫu nhiên, bắt buộc sử dụng API bảo mật của trình duyệt (`window.crypto.getRandomValues`) để đạt mức độ an toàn tối đa.

---

## 2. 🎨 Quy Chuẩn Giao Diện Người Dùng (UI/UX Style)

Tất cả các công cụ trong kho lưu trữ bắt buộc phải sử dụng một ngôn ngữ thiết kế đồng bộ, mang lại trải nghiệm cao cấp (Premium Dark Theme).

### A. Tích Hợp Stylesheet Dùng Chung
Mọi công cụ mới **BẮT BUỘC** phải liên kết tới tệp CSS dùng chung ở phần `<head>` kèm chuỗi phiên bản cache-busting:
```html
<link rel="stylesheet" href="./global.css?v=1.1">
```
*Lưu ý: Không viết các khối `<style>` nội tuyến khổng lồ làm loãng mã nguồn, chỉ viết các lớp CSS bổ sung cực kỳ đặc thù của công cụ đó nếu `global.css` chưa hỗ trợ.*

### B. Các Quy Tắc Thiết Kế Chi Tiết:
1.  **Cấu trúc Shell chuẩn:**
    Mọi công cụ phải được bao bọc trong một thẻ div có class là `.shell` hoặc `.root` tùy bố cục:
    ```html
    <div class="shell">
      <!-- Nút quay lại trang chủ -->
      <a href="./index.html" class="back-home">
        <i class="ti ti-arrow-left" aria-hidden="true"></i> Quay lại trang chủ
      </a>
      
      <!-- Header tiêu chuẩn -->
      <div class="header">
        <h1>Tên Công Cụ Mới</h1>
        <p>Mô tả ngắn gọn về chức năng của công cụ ở đây.</p>
      </div>
      
      <!-- Nội dung chính đặt trong các thẻ .panel -->
      <div class="panel">
        ...
      </div>
    </div>
    ```
2.  **Sử Dụng Biểu Tượng Hệ Thống:**
    Tích hợp thư viện biểu tượng **Tabler Icons** đã được nhúng sẵn trong `global.css`. Sử dụng cú pháp thẻ `<i>` dạng:
    ```html
    <i class="ti ti-key" aria-hidden="true"></i>
    ```
3.  **Khu Vực Kéo Thả (Dropzone) & Hàng Đợi Tệp Tin:**
    *   Sử dụng class `.dropzone` cho vùng nhận file kéo thả.
    *   Sử dụng class `.file-list` và các dòng `.file-row` (hoặc `.file-card`) để hiển thị danh sách tệp tin đang chờ hoặc đã xử lý xong.
    *   Trạng thái tệp tin sử dụng các màu neon tương ứng: `.st-proc` (đang xử lý - vàng), `.st-done` (đã xong - xanh lá), `.st-err` (lỗi - đỏ).
4.  **Bảng Nhật Ký Hoạt Động (Log Panel):**
    Nếu công cụ chạy tác vụ phức tạp (như md-to-epub), hãy tích hợp màn hình log dùng chung có class `.log-wrap` và lớp chứa nội dung `.log` để người dùng dễ theo dõi tiến trình trực quan.

---

## 3. 📦 Quy Định Sử Dụng Thư Viện Bên Thứ Ba (Libraries)

Chỉ sử dụng các thư viện Javascript bên thứ ba khi thực sự cần thiết và phải tuân theo các tiêu chí:

*   **Uy Tín & Phổ Biến:** Chỉ sử dụng các thư viện mã nguồn mở uy tín, được cộng đồng kiểm định kỹ lưỡng (Ví dụ: `marked` cho Markdown, `JSZip` cho nén file zip, `CryptoJS` nếu cần mã hóa cũ).
*   **Liên Kết CDN Đáng Tin Cậy:** Nhúng thư viện thông qua các CDN lớn, ổn định và có độ trễ thấp như **cdnjs** hoặc **jsdelivr** (ưu tiên cdnjs có mã kiểm tra tính toàn vẹn SRI).
*   **Không Dùng CDN Tải Script Động:** Tránh việc script tự động tải thêm các tài nguyên thực thi khác từ server lạ lúc runtime mà không có sự kiểm soát của lập trình viên.

---

## 4. 🔄 Quy Trình Tích Hợp Sau Khi Tạo Tool Mới

Sau khi viết xong mã nguồn cho công cụ mới (ví dụ: `new-tool.html`), bạn **PHẢI** thực hiện đầy đủ 3 bước tích hợp sau để đưa công cụ vào hoạt động chính thức:

### Bước 1: Cập Nhật README.MD
Thêm công cụ mới vào mục `## 📌 Danh sách công cụ` trong tệp **`README.MD`**:
*   Đặt tên công cụ kèm đường dẫn tương đối (Ví dụ: `### 4. 🛠️ [Công Cụ Mới](./new-tool.html)`).
*   Viết một đoạn tóm tắt **cực kỳ ngắn gọn** (2-4 dòng) giới thiệu chức năng và các tính năng nổi bật nổi bật nhất.

### Bước 2: Tự Động Biên Dịch Trang Chủ
Chạy kịch bản biên dịch Ruby bằng cách thực thi lệnh trong terminal:
```bash
ruby index-gen.rb
```
Kịch bản này sẽ tự động đọc nội dung cập nhật từ `README.MD`, biên dịch thành mã HTML chuẩn và ghi đè vào tệp **`index.html`** để cập nhật liên kết của công cụ mới lên trang chủ với giao diện tối đồng bộ.

### Bước 3: Đẩy Mã Nguồn Lên GitHub
Commit và đẩy các tệp tin mới lên kho lưu trữ để kích hoạt deploy tự động trên GitHub Pages:
```bash
git add README.MD index.html new-tool.html
git commit -m "feat: add new-tool utility using shared global.css"
git push origin main
```
