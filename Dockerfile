# Stage 1: Builder
FROM rust:alpine AS builder

RUN apk add --no-cache libpulse pulseaudio cargo alsa-lib-dev cargo-auditable rust-bindgen nasm cmake clang-libclang openssl-dev git

# Set the working directory
WORKDIR /app

# Clone the specified repository (replace <repository-url> with the actual URL)
RUN git clone -b dev https://github.com/librespot-org/librespot.git .

# Build the Rust application
RUN cargo build --release --features "pulseaudio-backend"

# Stage 2: Runner
FROM alpine:latest

RUN apk add --no-cache curl pulseaudio

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/librespot /usr/local/bin/

# setup librespot user
ENV HOME="/home/librespot_user"

RUN addgroup -g 1000 librespot_user \
  && adduser -u 1000 -G librespot_user -D -h "$HOME" librespot_user \
  && addgroup librespot_user audio \
  && addgroup librespot_user pulse \
  && addgroup librespot_user pulse-access \
  && chown -R librespot_user:librespot_user "$HOME"#

WORKDIR "$HOME"
COPY ./pulse /etc/pulse
USER librespot_user

EXPOSE 3465/tcp 3465/udp

# Set the command to run the application
ENTRYPOINT ["librespot", "--backend", "pulseaudio", "--zeroconf-port", "3465", "--disable-credential-cache", "on"]
CMD ["--name", "Bar Spotify", "--autoplay", "on"]
