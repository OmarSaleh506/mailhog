# Use a lightweight base image
FROM golang:1.14.7-alpine as builder

# Set the working directory
WORKDIR /go/src/app

# Fetch MailHog source code
RUN apk add --no-cache git \
    && go get github.com/mailhog/MailHog \
    && go get github.com/mailhog/mhsendmail

# Build MailHog
RUN go install github.com/mailhog/MailHog

# Create a new image
FROM alpine:latest

# Copy MailHog binary from the builder stage
COPY --from=builder /go/bin/MailHog /usr/local/bin/

# Expose MailHog ports
EXPOSE 1025 8025

# Set environment variables
ENV GOPATH=/go
ENV PATH=/go/bin:/usr/local/go/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Create a user for MailHog
RUN adduser -D -u 1000 mailhog

# Switch to the MailHog user
USER mailhog

# Set the working directory for the MailHog user
WORKDIR /home/mailhog

# Run MailHog with grep filtering for KEEPALIVE
CMD ["/bin/sh", "-c", "MailHog | grep -v KEEPALIVE"]
