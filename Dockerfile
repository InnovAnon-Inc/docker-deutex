FROM innovanon/doom-base as builder-03
USER root
COPY --from=innovanon/zlib       /tmp/zlib.txz       /tmp/
COPY --from=innovanon/bzip2      /tmp/bzip2.txz      /tmp/
COPY --from=innovanon/xz         /tmp/xz.txz         /tmp/
COPY --from=innovanon/libpng     /tmp/libpng.txz     /tmp/
COPY --from=innovanon/jpeg-turbo /tmp/jpeg-turbo.txz /tmp/
RUN cat   /tmp/*.txz  \
  | tar Jxf - -i -C / \
 && rm -v /tmp/*.txz
#RUN tar xf                       /tmp/zlib.txz       -C / \
# && tar xf                       /tmp/bzip2.txz      -C / \
# && tar xf                       /tmp/xz.txz         -C / \
# && tar xf                       /tmp/libpng.txz     -C / \
# && tar xf                       /tmp/jpeg-turbo.txz -C / \
# && rm -v                        /tmp/zlib.txz            \
#                                 /tmp/bzip2.txz           \
#                                 /tmp/xz.txz              \
#                                 /tmp/libpng.txz          \
#                                 /tmp/jpeg-turbo.txz

FROM builder-03 as deutex
ARG LFS=/mnt/lfs
USER lfs
RUN sleep 31 \
 && git clone --depth=1 --recursive          \
      https://github.com/Doom-Utils/deutex.git \
 && cd                            deutex     \ 
 && chmod -v +x bootstrap                    \
 && ./bootstrap                              \
 && ./configure                              \
      --disable-shared --enable-static       \
 && make                                     \
 && make DESTDIR=/tmp/deutex install         \
 && cd           /tmp/deutex                 \
 && tar acf        ../deutex.txz .           \
 && rm -rf           $LFS/sources/deutex

FROM scratch as final
COPY --from=deutex /tmp/deutex.txz /tmp/

