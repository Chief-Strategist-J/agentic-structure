# Multi-stage Dockerfile for Go service
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /go-svc ./cmd/api/main.go

FROM gcr.io/distroless/static-debian12:nonroot
WORKDIR /
COPY --from=builder /go-svc /go-svc
USER nonroot:nonroot
ENTRYPOINT ["/go-svc"]
