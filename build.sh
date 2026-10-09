#!/usr/bin/bash
# Build Dad's image and turn it into an installer ISO.  Run on the HOST (not in a toolbox).
#   ./build.sh                 -> Intel/AMD graphics (silverblue-main)
#   NVIDIA=1 ./build.sh        -> NVIDIA laptop (silverblue-nvidia)
#   IMAGE_REF=ghcr.io/<you>/dad-silverblue:latest ./build.sh   -> tag for pushing so Dad gets updates
set -euo pipefail
cd "$(dirname "$0")"

BASE=ghcr.io/ublue-os/silverblue-main:latest
[[ "${NVIDIA:-0}" == 1 ]] && BASE=ghcr.io/ublue-os/silverblue-nvidia:latest
LOCAL_TAG=localhost/dad-silverblue:latest
IMAGE_REF="${IMAGE_REF:-}"

sudo podman build --pull=newer --build-arg BASE_IMAGE="$BASE" -t "$LOCAL_TAG" .

cfg=config.toml
if [[ -n "$IMAGE_REF" ]]; then
    sudo podman tag "$LOCAL_TAG" "$IMAGE_REF"
    echo ">> Push it with: sudo podman push $IMAGE_REF"
    cfg=$(mktemp --suffix=.toml); sed "s|IMAGE_REF|$IMAGE_REF|" config.toml > "$cfg"
else
    echo ">> No IMAGE_REF: the installed laptop will NOT receive OS updates until you switch it to a registry image."
    cfg=$(mktemp --suffix=.toml); sed '/bootc switch/d' config.toml > "$cfg"
fi

mkdir -p output
sudo podman run --rm -it --privileged --pull=newer \
    --security-opt label=type:unconfined_t \
    -v "$cfg":/config.toml:ro \
    -v ./output:/output \
    -v /var/lib/containers/storage:/var/lib/containers/storage \
    quay.io/centos-bootc/bootc-image-builder:latest \
    --type anaconda-iso --rootfs btrfs --use-librepo=True \
    "$LOCAL_TAG"

echo ">> ISO: $(ls output/bootiso/*.iso)"
echo ">> Write it to a USB stick with Fedora Media Writer (already installed here)."
