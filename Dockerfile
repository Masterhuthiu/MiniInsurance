# Sử dụng Debian slim để dung lượng nhẹ nhưng vẫn đủ thư viện
FROM debian:bookworm-slim

# 1. Cài đặt các runtime cần thiết (GnuCOBOL và thư viện PostgreSQL)
RUN apt-get update && apt-get install -y \
    gnucobol \
    libpq5 \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 2. Copy các file thực thi đã được build từ bước CI vào image
# (GitHub Actions đã build xong FETCHTBL và FETCH-POLICY ở các step trước)
COPY FETCHTBL FETCH-POLICY ./

# 3. Cấu hình thư viện ocesql
# Bạn cần copy các file .so mà bạn đã tạo/copy ở bước CI vào đây
COPY OCESQLConnect.so /usr/local/lib/libocesql.so.0
COPY OCESQL.so /usr/local/lib/libocesql.so

# Cập nhật cache thư viện hệ thống
RUN ldconfig

# 4. Thiết lập biến môi trường để COBOL tìm thấy module
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV PGHOST=localhost
ENV PGPORT=5432

# Chạy ứng dụng mặc định
CMD ["./FETCHTBL"]