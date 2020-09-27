FROM alpine:edge

WORKDIR /home/csa

COPY analyzer.sh /home/csa

RUN apk update && \
    apk add --no-cache clang build-base clang-analyzer cmake make gcc git gawk libseccomp-dev && \
    chmod +x /home/csa/analyzer.sh

ENTRYPOINT [ "/home/csa/analyzer.sh" ]
CMD [""]