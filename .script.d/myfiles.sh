#!/usr/bin/env bash
set -euo pipefail

__media_dir="./"

echo "Setting up media ownership and permissions"
sudo chown -R --verbose "$(id -u)":"$(id -g)" "${__media_dir}"
sudo find "${__media_dir}" -type d -print -exec chmod 750 {} \;
sudo find "${__media_dir}" -type f -print -exec chmod 640 {} \;
