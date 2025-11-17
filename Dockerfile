# Stage 1: Builder
FROM rust:latest AS builder

# Set the working directory
WORKDIR /app

# Clone the specified repository (replace <repository-url> with the actual URL)
RUN git clone <repository-url> .

# Build the Rust application
RUN cargo build --release

# Stage 2: Runner
FROM debian:latest

# Install dependencies
RUN apt-get update && \
    apt-get install -y gcc libssl-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the built binary from the builder stage
COPY --from=builder /app/target/release/librespot /usr/local/bin/

# Set the command to run the application
CMD ["librespot"]
