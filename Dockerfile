FROM alpine:latest

RUN \
	mkdir -p /aws && \
	apk -Uuv add groff less python3 py3-pip sqlite && \
	pip3 install awscli && \
	apk --purge -v del py-pip && \
	rm /var/cache/apk/*

COPY entrypoint.sh /
COPY dobackup.sh /

RUN chmod +x /entrypoint.sh /dobackup.sh


ENTRYPOINT /entrypoint.sh
