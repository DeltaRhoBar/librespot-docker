FROM docker.io/library/alpine:edge

# Enable @testing tag to install from testing repository
RUN echo "@testing https://dl-cdn.alpinelinux.org/alpine/edge/testing" >> /etc/apk/repositories

# Install dependencies
RUN apk add --no-cache pulseaudio librespot@testing

# setup librespot user
ENV HOME="/home/librespot_user"

RUN addgroup -g 1000 librespot_user \
  && adduser -u 1000 -G librespot_user -D -h "$HOME" librespot_user \
  && addgroup librespot_user audio \
  && addgroup librespot_user pulse \
  && addgroup librespot_user pulse-access \
  && chown -R librespot_user:librespot_user "$HOME"

WORKDIR "$HOME"
COPY ./pulse /etc/pulse
USER librespot_user

EXPOSE 3465/tcp 3465/udp

# Set the command to run the application
ENTRYPOINT ["librespot", "--backend", "pulseaudio", "--zeroconf-port", "3465", "--disable-credential-cache", "on"]
CMD ["--name", "Bar Spotify", "--autoplay", "on"]
