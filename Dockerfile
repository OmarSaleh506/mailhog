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


WORKDIR /home/mailhog

# Run MailHog with custom host and port
CMD ["MailHog", "-api-bind-addr", "0.0.0.0:8025", "-ui-bind-addr", "0.0.0.0:8025"]
