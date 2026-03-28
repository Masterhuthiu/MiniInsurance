FROM debian:bookworm-slim

# 1. Cài đặt các công cụ cần thiết (GnuCOBOL, Postgres Client, Build Tools)
RUN apt-get update && apt-get install -y \
    gnucobol libpq-dev postgresql-client git make gcc autoconf libtool bison flex \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL (ocesql) vào hệ thống
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git /tmp/ocesql \
    && cd /tmp/ocesql && ./autogen.sh && ./configure && make && make install && ldconfig

# 3. Thiết lập thư mục làm việc
WORKDIR /app
COPY . .

# 4. BIÊN DỊCH SẴN: Chuyển ESQL sang COBOL và tạo file thực thi FETCHTBL
# Bước này giúp bạn không cần gõ lệnh biên dịch thủ công sau khi pull
RUN ocesql FETCHTBL.cbl FETCHTBL.cob && \
    cobc -x -fixed FETCHTBL.cob /usr/local/lib/libocesql.so -lpq -o FETCHTBL && \
    chmod +x FETCHTBL

# 5. CẤU HÌNH SẴN: Biến môi trường để kết nối DB và tìm thư viện
ENV PGHOST=db \
    PGUSER=postgres \
    PGDATABASE=insurandb \
    LD_LIBRARY_PATH=/usr/local/lib \
    COB_LIBRARY_PATH=/usr/local/lib

# 6. MẶC ĐỊNH: Chạy luôn chương trình khi container khởi động
CMD ["./FETCHTBL"]