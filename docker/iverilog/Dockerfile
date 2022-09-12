ARG RUN_BASE_IMAGE=
ARG BUILD_BASE_IMAGE=
FROM ${BUILD_BASE_IMAGE} AS builder
 
ARG IVERILOG_REPO
ARG IVERILOG_COMMIT
 
RUN yum install -y flex bison autoconf libtool gperf tcl-devel libcurl-devel openssl-devel zlib-devel
 
WORKDIR /iverilog
RUN curl -L ${IVERILOG_REPO}/tarball/${IVERILOG_COMMIT} | tar -xzC . --strip-components=1 && \
    sh autoconf.sh && \
    ./configure --prefix=/build && \
    make -j$(nproc) && \
    make install
 
RUN mkdir -p /build/version/
RUN date +"Build Timestamp: %Y-%m-%d_%H-%M-%S" > /build/version/iverilog.version
RUN echo ${IVERILOG_COMMIT} >> /build/version/iverilog.version
RUN tar -czf /build.tar.gz /build
 
# ---
FROM ${RUN_BASE_IMAGE} AS runnable
ENV PATH /build/bin:$PATH
 
COPY --from=builder /build /build
COPY --from=builder /build.tar.gz /build.tar.gz