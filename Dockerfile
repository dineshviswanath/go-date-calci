# Build Stage
FROM lacion/alpine-golang-buildimage:1.12.4 AS build-stage

LABEL app="build-go-date-calci"
LABEL REPO="https://github.com/dineshviswanath/go-date-calci"

ENV PROJPATH=/go/src/github.com/dineshviswanath/go-date-calci

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:$GOROOT/bin:$GOPATH/bin

ADD . /go/src/github.com/dineshviswanath/go-date-calci
WORKDIR /go/src/github.com/dineshviswanath/go-date-calci

RUN make build-alpine

# Final Stage
FROM lacion/alpine-base-image:latest

ARG GIT_COMMIT
ARG VERSION
LABEL REPO="https://github.com/dineshviswanath/go-date-calci"
LABEL GIT_COMMIT=$GIT_COMMIT
LABEL VERSION=$VERSION

# Because of https://github.com/docker/docker/issues/14914
ENV PATH=$PATH:/opt/go-date-calci/bin

WORKDIR /opt/go-date-calci/bin

COPY --from=build-stage /go/src/github.com/dineshviswanath/go-date-calci/bin/go-date-calci /opt/go-date-calci/bin/
RUN chmod +x /opt/go-date-calci/bin/go-date-calci

# Create appuser
RUN adduser -D -g '' go-date-calci
USER go-date-calci

ENTRYPOINT ["/usr/bin/dumb-init", "--"]

CMD ["/opt/go-date-calci/bin/go-date-calci"]
