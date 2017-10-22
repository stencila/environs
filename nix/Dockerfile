FROM alpine@sha256:f006ecbb824d87947d0b51ab8488634bf69fe4094959d935c0c103f4820a417d

# Enable HTTPS support in wget.
RUN apk add --update openssl

RUN mkdir /nix \
  && chown guest /nix \
  && mkdir /home/guest \
  && chown guest /home/guest

USER guest

ENV HOME=/home/guest \
    USER=guest
WORKDIR /home/guest

RUN wget -O- https://nixos.org/releases/nix/nix-1.11.14/nix-1.11.14-x86_64-linux.tar.bz2 | bzcat - | tar xf - \
  && sh nix-*-x86_64-linux/install \
  && rm -r nix-*-x86_64-linux

ONBUILD ENV \
    ENV=/etc/profile \
    PATH=/home/guest/.nix-profile/bin:/home/guest/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GIT_SSL_CAINFO=/home/guest/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=/home/guest/.nix-profile/etc/ssl/certs/ca-bundle.crt

ENV \
    ENV=/etc/profile \
    PATH=/home/guest/.nix-profile/bin:/home/guest/.nix-profile/sbin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    GIT_SSL_CAINFO=/home/guest/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_SSL_CERT_FILE=/home/guest/.nix-profile/etc/ssl/certs/ca-bundle.crt \
    NIX_PATH='nixpkgs=/home/guest/.nix-defexpr/channels/nixpkgs' \
    NIX_LINK=/home/guest/.nix-profile

