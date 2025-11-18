# Stage 1: Builder
FROM rust:latest AS builder

RUN apt-get update && \
    apt-get install -y libpulse-dev libasound2-dev pkg-config && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Clone the specified repository (replace <repository-url> with the actual URL)
RUN git clone -b dev https://github.com/librespot-org/librespot.git .

# Build the Rust application
RUN cargo build --release --features "pulseaudio-backend"

# Stage 2: Runner
FROM debian:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y pulseaudio && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/librespot /usr/local/bin/
# setup librespot user
ENV HOME="/home/librespot"
ENV PULSE_SERVER="tcp:host.containers.internal:4713"
RUN groupadd --gid 1000 librespot \
  && useradd --uid 1000 --gid 1000 --create-home --home-dir "$HOME" librespot \
  && usermod -aG audio,pulse,pulse-access librespot \
  && chown -R librespot:librespot "$HOME"
WORKDIR "$HOME"
COPY ./ledfx_docker/pulse /etc/pulse
USER librespot

# Set the command to run the application
CMD ["/usr/local/bin/librespot"]
