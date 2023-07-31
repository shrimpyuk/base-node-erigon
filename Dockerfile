# syntax=docker/dockerfile:1-labs
FROM golang:1.19 as op

WORKDIR /app

ENV REPO=https://github.com/ethereum-optimism/optimism
ENV VERSION=v1.1.1
ENV CHECKSUM=c0f3dbce8729016103b8390f9ee81089cd858242df6a45a42c59555f1c9e9106
ADD --checksum=sha256:$CHECKSUM $REPO/archive/op-node/$VERSION.tar.gz ./

RUN tar -xvf ./$VERSION.tar.gz --strip-components=1 && \
    cd op-node && \
    make op-node

FROM golang:1.19 as erigon

WORKDIR /app

ENV REPO=https://github.com/shrimpyuk/base-node-erigon
ENV VERSION=v2.48.1-0.1.9-base
ENV CHECKSUM=5a51ed37d453144b477bc4b4d9fbbdefedc758f0787be986e1ec4111a2a45df6
ADD --checksum=sha256:$CHECKSUM $REPO/archive/$VERSION.tar.gz ./

RUN tar -xvf ./$VERSION.tar.gz --strip-components=1 && \
    make erigon

FROM golang:1.19

RUN apt-get update && \
    apt-get install -y jq curl && \
    rm -rf /var/lib/apt/lists

WORKDIR /app

COPY --from=op /app/op-node/bin/op-node ./
COPY --from=erigon /app/build/bin/erigon ./
COPY erigon-entrypoint .
COPY op-node-entrypoint .
COPY goerli ./goerli
COPY mainnet ./mainnet
