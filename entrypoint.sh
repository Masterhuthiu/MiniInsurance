#!/bin/bash
set -e

# Khởi động dịch vụ Postgres
service postgresql start

# Kiểm tra nếu DB chưa có dữ liệu thì chèn (tùy chọn)
# psql -U postgres -d insurandb -f /app/init_data.sql

echo "Postgres is running on localhost:5432"

# Giữ container chạy bằng cách chạy ứng dụng của bạn hoặc shell
exec bash