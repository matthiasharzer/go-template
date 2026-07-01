FROM golang:1.26.4-alpine3.23 AS build

ARG version

RUN if [ -z "$version" ]; then \
			echo "version is not set"; \
			exit 1; \
    fi

RUN apk update && \
		apk add git

WORKDIR /go/src

COPY go.mod go.sum ./
RUN go mod download && \
		go mod verify

COPY . .

RUN module_path=$(go list -m) && \
	go build \
		-o /go/bin/<tool-name> \
		-ldflags "-X ${module_path}/cmd/version.version=$version" \
		.

FROM alpine:3.24

COPY --from=build /go/bin/<tool-name> /usr/local/bin/<tool-name>

WORKDIR /var/lib/<tool-name>

ENTRYPOINT ["/usr/local/bin/<tool-name>"]
