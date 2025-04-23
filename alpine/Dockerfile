ARG POSTGRES_VERSION=17

FROM docker.io/library/postgres:${POSTGRES_VERSION}-alpine AS build

ARG CFLAGS="-march=core2 -O3 -DNDEBUG"
ARG CXXFLAGS="-march=core2 -O3 -DNDEBUG"
ARG PGRN_DEBUG=""
ARG PGROONGA_VERSION=4.0.1
ARG GROONGA_VERSION=15.0.4

ENV PGRN_DEBUG=${PGRN_DEBUG} \
  PGROONGA_VERSION=${PGROONGA_VERSION} \
  GROONGA_VERSION=${GROONGA_VERSION} \
  CFLAGS=${CFLAGS} \
  CXXFLAGS=${CXXFLAGS}

COPY alpine/build.sh /
RUN \
  apk add --no-cache --virtual=.build-dependencies \
  apache-arrow-dev \
  build-base \
  clang19-dev \
  cmake \
  gettext-dev \
  linux-headers \
  llvm19 \
  lz4-dev \
  msgpack-c-dev \
  rapidjson-dev \
  ruby \
  samurai \
  xsimd-dev \
  xxhash-dev \
  zlib-dev \
  zstd-dev && \
  /build.sh ${PGROONGA_VERSION} ${GROONGA_VERSION} && \
  rm -f build.sh && \
  apk del .build-dependencies && \
  apk add --no-cache \
  libarrow \
  libxxhash \
  msgpack-c \
  zlib \
  zstd

RUN mkdir -p /target/docker-entrypoint-initdb.d

COPY --chmod=555 alpine/000-pgroonga.sh /target/docker-entrypoint-initdb.d/000-pgroonga.sh

RUN chmod 555 /target/docker-entrypoint-initdb.d/000-pgroonga.sh

FROM postgres:${POSTGRES_VERSION}-alpine

RUN apk add --no-cache \
  libarrow \
  libxxhash \
  msgpack-c \
  zlib \
  zstd

COPY --from=build /target /
