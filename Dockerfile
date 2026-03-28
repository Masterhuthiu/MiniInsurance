FROM debian:bookworm-slim

# 1. Cài đặt GnuCOBOL và các thư viện hỗ trợ
RUN apt-get update && apt-get install -y \
    gnucobol libpq-dev postgresql-client git make gcc autoconf libtool bison flex pkg-config \
    && rm -rf /var/lib/apt/lists/*

# 2. Cài đặt Open-COBOL-ESQL (ocesql)
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git /tmp/ocesql \
    && cd /tmp/ocesql && ./autogen.sh && ./configure && make && make install && ldconfig

# --- BƯỚC FIX LỖI: Tạo Symbolic Links cho các module SQL ---
RUN ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQLConnect.so && \
    ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQL.so

# 3. Copy code và BIÊN DỊCH SẴN
WORKDIR /app
COPY . .

# Chuyển ESQL sang COBOL và tạo file thực thi
RUN ocesql FETCHTBL.cbl FETCHTBL.cob && \
    cobc -x -fixed FETCHTBL.cob /usr/local/lib/libocesql.so -lpq -o FETCHTBL && \
    chmod +x FETCHTBL

# 4. Cấu hình môi trường
ENV PGHOST=db \
    PGUSER=postgres \
    PGDATABASE=insurandb \
    LD_LIBRARY_PATH=/usr/local/lib \
    COB_LIBRARY_PATH=/usr/local/lib

# 5. Lệnh mặc định
CMD ["./FETCHTBL"]