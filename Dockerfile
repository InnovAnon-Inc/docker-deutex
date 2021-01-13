FROM innovanon/doom-base as builder-03
USER root
COPY --from=innovanon/zlib       /tmp/zlib.txz       /tmp/
COPY --from=innovanon/bzip2      /tmp/bzip2.txz      /tmp/
COPY --from=innovanon/xz         /tmp/xz.txz         /tmp/
COPY --from=innovanon/libpng     /tmp/libpng.txz     /tmp/
COPY --from=innovanon/jpeg-turbo /tmp/jpeg-turbo.txz /tmp/
RUN extract.sh

FROM builder-03 as deutex
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && command -v strip.sh                 \
 && git clone --depth=1 --recursive          \
      https://github.com/Doom-Utils/deutex.git \
 && cd                            deutex     \ 
 && chmod -v +x bootstrap                    \
 && ./bootstrap                              \
 && ./configure                              \
      --disable-shared --enable-static       \
      "${CONFIG_OPTS[@]}"                    \
 && make                                     \
 && make DESTDIR=/tmp/deutex install         \
 && cd           /tmp/deutex                 \
 && strip.sh .                               \
 && tar  pacf        ../deutex.txz .           \
 && rm -rf           $LFS/sources/deutex

FROM scratch as final
COPY --from=deutex /tmp/deutex.txz /tmp/

