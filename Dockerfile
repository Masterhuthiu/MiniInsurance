FROM debian:bookworm-slim

# 1. Cài đặt GnuCOBOL, Postgres Client và PYTHON
RUN apt-get update && apt-get install -y \
    gnucobol libpq-dev postgresql-client postgresql postgresql-contrib git make gcc autoconf libtool bison flex pkg-config \
    python3 python3-pip python3-venv \
    && rm -rf /var/lib/apt/lists/*
# 2. Cấu hình Postgres để cho phép kết nối local không cần password (để dev nhanh)
USER postgres
RUN /etc/init.d/postgresql start && \
    psql --command "CREATE USER admin WITH SUPERUSER PASSWORD 'admin';" && \
    psql --command "CREATE DATABASE insurandb;" 
# 3. Quay lại quyền root để cài đặt App
USER root
# 2. Cài đặt Open-COBOL-ESQL (ocesql)
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git /tmp/ocesql \
    && cd /tmp/ocesql && ./autogen.sh && ./configure && make && make install && ldconfig

# FIX LỖI: Tạo Symbolic Links cho các module SQL
RUN ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQLConnect.so && \
    ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQL.so

# 3. Thiết lập thư mục làm việc và copy code
WORKDIR /app
COPY . .

# 4. Biên dịch COBOL thành file thực thi (Executable)
RUN ocesql FETCHTBL.cbl FETCHTBL.cob && \
    cobc -x -fixed FETCHTBL.cob /usr/local/lib/libocesql.so -lpq -o FETCHTBL && \
    chmod +x FETCHTBL

# 5. Cài đặt thư viện Python (FastAPI & Uvicorn)
RUN pip3 install --no-cache-dir fastapi uvicorn --break-system-packages

# 6. Cấu hình môi trường (Biến môi trường cho cả COBOL và Python)
ENV PGHOST=db \
    PGUSER=postgres \
    PGDATABASE=insurandb \
    LD_LIBRARY_PATH=/usr/local/lib \
    COB_LIBRARY_PATH=/usr/local/lib \
    PYTHONUNBUFFERED=1

# 7. Lệnh mặc định: Khởi chạy Python API (Giả sử file API của bạn tên là main.py)
# Nếu bạn muốn chạy thẳng COBOL như cũ thì đổi thành ["./FETCHTBL"]
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]