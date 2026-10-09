# Dad's laptop: same base as this machine, minus personal data, plus senior-friendly defaults.
# Use silverblue-nvidia only if Dad's laptop has an NVIDIA GPU; otherwise -main is lighter and safer.
ARG BASE_IMAGE=ghcr.io/ublue-os/silverblue-main:latest
FROM ${BASE_IMAGE}

# Windows-like taskbar + Start menu (same extensions as this machine), tray icons
RUN dnf -y install \
        gnome-shell-extension-dash-to-panel \
        gnome-shell-extension-appindicator \
    && dnf clean all \
    && rm -rf /run/dnf /var/log/dnf5.log /var/cache/libdnf5 /var/lib/dnf /var/cache/ldconfig/aux-cache

# ArcMenu isn't packaged for Fedora 44: fetch the build matching this image's GNOME version
RUN SHELL_VER=$(gnome-shell --version | grep -oE '[0-9]+' | head -1) \
    && curl -fsSL -o /tmp/arcmenu.zip \
       "https://extensions.gnome.org/download-extension/arcmenu@arcmenu.com.shell-extension.zip?shell_version=${SHELL_VER}" \
    && mkdir -p /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com \
    && python3 -m zipfile -e /tmp/arcmenu.zip /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com \
    && glib-compile-schemas /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas \
    && cp /usr/share/gnome-shell/extensions/arcmenu@arcmenu.com/schemas/*.gschema.xml /usr/share/glib-2.0/schemas/ \
    && glib-compile-schemas /usr/share/glib-2.0/schemas \
    && rm /tmp/arcmenu.zip

# System-wide defaults (dconf) + first-boot app installer
COPY files/ /
RUN chmod +x /usr/libexec/dad-firstboot-flatpaks \
    && systemctl enable dad-firstboot-flatpaks.service rpm-ostreed-automatic.timer \
    && dconf update \
    && bootc container lint
