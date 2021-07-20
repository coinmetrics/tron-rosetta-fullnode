FROM ubuntu:18.04 as builder

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		patch \
		openjdk-8-jdk-headless \
		openjfx \
		libopenjfx-java \
		libopenjfx-jni \
	; \
	rm -rf /var/lib/apt/lists/*

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron

ARG VERSION

RUN set -ex; \
	mkdir /home/tron/tron-rosetta-api; \
	curl -L https://github.com/tronprotocol/tron-rosetta-api/archive/v${VERSION}.tar.gz | tar -xz --strip-components=1 -C /home/tron/tron-rosetta-api

RUN set -ex; \
	cd /home/tron/tron-rosetta-api; \
	./gradlew build -x test


FROM ubuntu:18.04

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends \
		curl \
		patch \
		openjdk-8-jre-headless \
		openjfx \
		libopenjfx-java \
		libopenjfx-jni \
	; \
	rm -rf /var/lib/apt/lists/*

COPY --from=builder /home/tron/tron-rosetta-api/build/libs/tron-rosetta-api-1.0.0.jar /opt/tron-rosetta-api.jar

RUN curl -o /opt/config.conf -L https://raw.githubusercontent.com/tronprotocol/tron-rosetta-api/master/src/main/resources/net_conf/mainnet.conf

RUN useradd -m -u 1000 -s /bin/bash tron
USER tron
WORKDIR /opt/data
