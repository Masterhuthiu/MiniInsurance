FROM debian:bookworm-slim

# 1. Cài đặt các phụ thuộc hệ thống
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

# 2. Build và Install Open-COBOL-ESQL (ocesql)
RUN git clone --depth 1 https://github.com/opensourcecobol/Open-COBOL-ESQL.git /tmp/ocesql \
    && cd /tmp/ocesql \
    && ./autogen.sh \
    && ./configure CPPFLAGS="-I/usr/include/postgresql" \
    && make \
    && make install \
    && ldconfig

# 3. Tạo Symbolic Links để GnuCOBOL tìm thấy module lúc Runtime
RUN ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQLConnect.so \
    && ln -s /usr/local/lib/libocesql.so /usr/local/lib/OCESQL.so

# 4. Thiết lập thư mục làm việc và biến môi trường mặc định
WORKDIR /app
ENV LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
ENV COB_LIBRARY_PATH=/usr/local/lib

# Copy toàn bộ code vào image (để CI có cái mà chạy)
COPY . .

CMD ["bash"]