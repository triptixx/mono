ARG ALPINE_TAG=3.13
ARG MONO_VER=6.12.0.126

FROM loxoo/alpine:${ALPINE_TAG} AS builder

ARG MONO_VER
ARG MONO_BUILD=/mono-build

### install mono-runtime
WORKDIR /mono-src
RUN apk add --no-cache build-base autoconf automake libtool cmake linux-headers zlib-dev python3 git gettext curl; \
    ln -s /usr/bin/python3 /usr/bin/python; \
    git clone https://github.com/mono/mono.git --branch mono-${MONO_VER} --depth 1 .; \
    ./autogen.sh --disable-boehm \
                 --enable-small-config \
                 --without-x \
                 --without-sigaltstack \
                 --with-mcs-docs=no; \
    make get-monolite-latest; \
    make; \
    make install DESTDIR=${MONO_BUILD}

WORKDIR $MONO_BUILD
COPY libmono.txt /tmp/
RUN mkdir /output; \
    while IFS= read -r line; do \
        cp -a --parents ".${line}" /output/; \
    done < /tmp/libmono.txt; \
    find ./usr/local/lib/mono/4.5/ -iname *.dll -type l -exec cp -a --parents {} /output/ \; \
        -exec sh -c 'cp -a --parents ./usr/local/lib/mono/gac/$(basename "$1" .dll) /output/' _ {} \;; \
    find /output/ -exec sh -c 'file "{}" | grep -q ELF && strip --strip-debug "{}"' \;

#===============================================================

FROM loxoo/alpine:${ALPINE_TAG}

ARG MONO_VER

LABEL org.label-schema.name="mono-runtime" \
      org.label-schema.description="A bare minimum Mono runtime docker image, based on Alpine" \
      org.label-schema.url="https://www.mono-project.com" \
      org.label-schema.version=${MONO_VER}

COPY --from=builder /output/ /

RUN apk add --no-cache libgcc ca-certificates; \
    cert-sync /etc/ssl/certs/ca-certificates.crt; \
    apk del --no-cache ca-certificates
