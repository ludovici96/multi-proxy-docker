FROM alpine:3.16 as build
WORKDIR /app
RUN apk update && apk add --no-cache curl go musl-dev bash tzdata git && \
    git clone https://github.com/skandix/Beetroot.git . && \
    go mod tidy
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o beetroot ./cmd/beetroot/main.go

FROM alpine:3.16 as release
COPY --from=build /usr/share/zoneinfo /usr/share/zoneinfo
ENV TZ=Europe/Oslo
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
WORKDIR /app
COPY --from=build /app/beetroot /app/beetroot
ENTRYPOINT ["./beetroot"]