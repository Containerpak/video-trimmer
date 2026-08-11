FROM ghcr.io/containerpak/gtk-sdk:main AS build

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    blueprint-compiler ca-certificates cargo curl gettext rustc && \
    curl -fsSL https://gitlab.gnome.org/YaLTeR/video-trimmer/-/archive/1c75471cc01ac3b58f2995814870ce5074932d3b/video-trimmer-1c75471cc01ac3b58f2995814870ce5074932d3b.tar.gz \
      -o /tmp/video-trimmer.tar.gz && \
    echo '951ea2658e6813c82312ad3a8f0de576fd47245e6d7a16fa6d7028d225066bb8  /tmp/video-trimmer.tar.gz' | sha256sum -c - && \
    mkdir -p /tmp/video-trimmer && \
    tar -xzf /tmp/video-trimmer.tar.gz -C /tmp/video-trimmer --strip-components=1 && \
    meson setup /tmp/video-trimmer/build /tmp/video-trimmer --prefix=/usr && \
    DESTDIR=/opt/stage meson install -C /tmp/video-trimmer/build

FROM ghcr.io/containerpak/gtk:main

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ffmpeg gstreamer1.0-libav gstreamer1.0-plugins-bad \
    gstreamer1.0-plugins-good gstreamer1.0-pulseaudio && \
    cpak-clean-junk

COPY --from=build /opt/stage/usr /usr
