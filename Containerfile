FROM ghcr.io/containerpak/gtk4-sdk:main AS build

ARG DEBIAN_FRONTEND=noninteractive

ADD --checksum=sha256:951ea2658e6813c82312ad3a8f0de576fd47245e6d7a16fa6d7028d225066bb8 https://gitlab.gnome.org/YaLTeR/video-trimmer/-/archive/1c75471cc01ac3b58f2995814870ce5074932d3b/video-trimmer-1c75471cc01ac3b58f2995814870ce5074932d3b.tar.gz /tmp/video-trimmer.tar.gz

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    blueprint-compiler cargo desktop-file-utils gettext libglib2.0-bin rustc && \
    mkdir -p /tmp/video-trimmer && \
    tar -xzf /tmp/video-trimmer.tar.gz -C /tmp/video-trimmer --strip-components=1 && \
    meson setup /tmp/video-trimmer/build /tmp/video-trimmer --prefix=/usr && \
    DESTDIR=/opt/stage meson install -C /tmp/video-trimmer/build

FROM ghcr.io/containerpak/adwaita:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-pulseaudio && \
    cpak-clean-junk

COPY --from=build /opt/stage/usr /usr
