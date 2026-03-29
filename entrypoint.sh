#!/bin/bash
set -e

# --- 1. Khởi động dịch vụ PostgreSQL ---
echo "Starting PostgreSQL server..."
service postgresql start

# Đợi một chút để Postgres sẵn sàng
until pg_isready -h localhost -p 5432; do
  echo "Waiting for database to be ready..."
  sleep 2
done

# --- 2. Kiểm tra và Khởi tạo dữ liệu (Nếu cần) ---
# Bước này giúp đảm bảo mỗi khi bạn chạy container mới, 
# bảng POLICIESM luôn có sẵn 10 dòng dữ liệu mẫu.
echo "Checking database 'insurandb'..."
DB_EXISTS=$(psql -U postgres -lqt | cut -d \| -f 1 | grep -w insurandb | wc -l)

if [ "$DB_EXISTS" -eq 0 ]; then
    echo "Creating database and tables..."
    psql -U postgres -c "CREATE DATABASE insurandb;"
    
    # Chạy script tạo bảng và insert 10 dòng (Giả sử bạn để file sql trong /app/init.sql)
    # Hoặc chạy trực tiếp tại đây:
    psql -U postgres -d insurandb <<EOF
    CREATE TABLE IF NOT EXISTS POLICIESM (
        POL_ID INT PRIMARY KEY,
        SUFFIX VARCHAR(10),
        OWNER_NAME VARCHAR(100),
        POL_STATUS VARCHAR(50),
        PROD_NAME VARCHAR(100),
        COVG_QTY INT,
        GROSS_PREM DECIMAL(18,2),
        MODAL_PREM DECIMAL(18,2),
        TRUE_PREM DECIMAL(18,2),
        PAID_TO_DT DATE,
        DISC_AMT DECIMAL(18,2)
    );
    INSERT INTO POLICIESM VALUES (1001, 'IND', 'NGUYEN VAN A', 'ACTIVE', 'LIFE GOLD', 2, 1200.00, 100.00, 95.00, '2026-12-31', 5.00);
    -- (Bạn có thể thêm tiếp 9 dòng còn lại ở đây)
EOF
fi

echo "PostgreSQL is ready on localhost:5432"

# --- 3. Thực thi lệnh chính ---
# Nếu bạn truyền lệnh khi 'docker run', nó sẽ thực thi lệnh đó.
# Nếu không truyền gì, nó sẽ mở Bash để bạn vào gõ lệnh.
if [ $# -eq 0 ]; then
    echo "No command provided, starting Bash..."
    exec bash
else
    echo "Executing command: $@"
    exec "$@"
fi