#!/usr/bin/env bash

# Installs Docker Engine and the Docker Compose v2 plugin on supported Ubuntu hosts.

set -Eeuo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Run this script with sudo or as root." >&2
  exit 1
fi

if [[ ! -r /etc/os-release ]]; then
  echo "Cannot identify the operating system: /etc/os-release is missing." >&2
  exit 1
fi

. /etc/os-release

if [[ "${ID}" != "ubuntu" ]]; then
  echo "This script supports Ubuntu only; detected: ${ID}." >&2
  exit 1
fi

docker_user="${1:-__DOCKER_USER__}"

export DEBIAN_FRONTEND=noninteractive

# Ubuntu cloud-init and unattended-upgrades can still be installing packages
# when the Custom Script Extension starts. Wait for cloud-init, then let APT
# wait for its dpkg lock and retry transient package-manager failures. Never
# remove lock files: doing so can corrupt the dpkg database.
if command -v cloud-init >/dev/null 2>&1; then
  echo "Waiting for cloud-init to finish package provisioning..."
  if ! timeout 600 cloud-init status --wait; then
    echo "cloud-init did not complete cleanly within 10 minutes; continuing with APT lock handling." >&2
  fi
fi

apt_get() {
  local attempts=0
  local max_attempts=3

  until apt-get -o DPkg::Lock::Timeout=600 "$@"; do
    attempts=$((attempts + 1))

    if ((attempts >= max_attempts)); then
      echo "APT command failed after ${attempts} attempts: apt-get $*" >&2
      return 1
    fi

    echo "APT command failed; retrying in 15 seconds (${attempts}/${max_attempts})..." >&2
    sleep 15
  done
}

if ! dpkg-query --show --showformat='${db:Status-Status}' docker-ce 2>/dev/null | grep -qx installed; then
  # Remove packages that conflict with Docker's official packages. Docker data
  # in /var/lib/docker is not purged by apt remove.
  apt_get remove -y \
    docker.io docker-compose docker-compose-v2 docker-doc docker-buildx \
    podman-docker containerd runc || true
fi

apt_get update
apt_get install -y ca-certificates curl

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

cat >/etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: ${UBUNTU_CODENAME:-$VERSION_CODENAME}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF

apt_get update
apt_get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

systemctl enable --now docker

if [[ -n "${docker_user}" ]]; then
  if ! id "${docker_user}" >/dev/null 2>&1; then
    echo "The requested Docker user does not exist: ${docker_user}" >&2
    exit 1
  fi

  usermod -aG docker "${docker_user}"
  echo "Added ${docker_user} to the docker group. Sign out and back in before using Docker without sudo."
fi

docker --version
docker compose version
systemctl --no-pager --full status docker
