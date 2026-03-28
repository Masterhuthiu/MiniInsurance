FROM debian:bookworm-slim

# 1. Cài đặt các công cụ cần thiết (Đã thêm pkg-config)
RUN apt-get update && apt-get install -y \
    gnucobol \
    libpq-dev \
    postgresql-client \
    git \
    make \
    gcc \
    autoconf \
    libtool \
    bison \
    flex \
    pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL (ocesql) vào hệ thống
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git /tmp/ocesql \
    && cd /tmp/ocesql \
    && ./autogen.sh \
    && ./configure CPPFLAGS="-I/usr/include/postgresql" \
    && make \
    && make install \
    && ldconfig

# 3. Thiết lập thư mục làm việc và Copy code
WORKDIR /app
COPY . .

# 4. BIÊN DỊCH SẴN: Tạo file thực thi FETCHTBL
RUN ocesql FETCHTBL.cbl FETCHTBL.cob && \
    cobc -x -fixed FETCHTBL.cob /usr/local/lib/libocesql.so -lpq -o FETCHTBL && \
    chmod +x FETCHTBL

# 5. CẤU HÌNH SẴN: Biến môi trường
ENV PGHOST=db \
    PGUSER=postgres \
    PGDATABASE=insurandb \
    LD_LIBRARY_PATH=/usr/local/lib \
    COB_LIBRARY_PATH=/usr/local/lib

# 6. MẶC ĐỊNH: Chạy luôn chương trình
CMD ["./FETCHTBL"]