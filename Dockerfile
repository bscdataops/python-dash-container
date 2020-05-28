FROM alpine:3.11

ENV PYTHONUNBUFFERED=1

RUN echo "**** install Python ****" && \
    apk add --no-cache python3 && \
    if [ ! -e /usr/bin/python ]; then ln -sf python3 /usr/bin/python ; fi && \
    \
    echo "**** install pip ****" && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    pip3 install --no-cache --upgrade pip setuptools wheel && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip ; fi

RUN apk add --no-cache \
        --virtual=.build-dependencies \
        g++ gfortran file binutils \
        musl-dev python3-dev cython openblas-dev lapack-dev && \
    apk add libstdc++ openblas lapack && \
    \
    ln -s locale.h /usr/include/xlocale.h && \
    \
    pip install --disable-pip-version-check --no-build-isolation numpy && \
    pip install --disable-pip-version-check --no-build-isolation pandas && \
    pip install --no-cache-dir dash && \
    pip install --no-cache-dir mysql-connector-python && \
    rm -r /root/.cache && \
    find /usr/lib/python3.*/ -name 'tests' -exec rm -r '{}' + && \
    find /usr/lib/python3.*/site-packages/ -name '*.so' -print -exec sh -c 'file "{}" | grep -q "not stripped" && strip -s "{}"' \; && \
    rm /usr/include/xlocale.h && \
    apk del .build-dependencies