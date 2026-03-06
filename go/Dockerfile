# Stage 1: Build the Go application
FROM golang:1.26-alpine AS builder
WORKDIR /app
# Copy all source files
COPY main.go index.html .
# Inject the build time dynamically during compilation
RUN go build -ldflags="-X 'main.BuildTime=$(date -u +%Y-%m-%dT%H:%M:%SZ)'" -o server main.go

# Stage 2: Create a minimal production image
FROM alpine:latest
WORKDIR /root/
COPY --from=builder /app/server .
EXPOSE 8080
# Run the compiled binary
CMD ["./server"]
