#!/usr/bin/env bash
set -euo pipefail

LATEST_VERSION="$(curl -s \
    "https://api.github.com/repos/dbeaver/dbeaver/releases/latest" |
    jq -r ".tag_name")"

if [[ -z "${LATEST_VERSION}" ]]; then
    echo "Failed to get latest version."
    exit 1
fi

rm -rf "${HOME}/.local/share/dbeaver"

TMP_DOWNLOAD_DIRECTORY="${HOME}/.tmp/from_dotfiles_bin"

mkdir -p "${TMP_DOWNLOAD_DIRECTORY}" "${HOME}/.local/share/dbeaver-ce" "${HOME}/.local/share/applications/"
echo "Downloading DBeaver version ${LATEST_VERSION} for $(uname -m) architecture to ${TMP_DOWNLOAD_DIRECTORY}"

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz" ]]; then
    curl -fL "https://dbeaver.io/files/${LATEST_VERSION}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz"
else
    echo "Tarball File already exists"
fi

if [[ ! -f "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz.sha256" ]]; then
    curl -fL "https://dbeaver.io/files/${LATEST_VERSION}/checksum/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz.sha256" \
        -o "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz.sha256"
else
    echo "Checksum File already exists"
fi

echo "Verifying checksum."
CURRENT_CHECKSUM="$(sha256sum "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz" |
    awk '{print $1}')"
EXPECTED_CHECKSUM="$(cat "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz.sha256" |
    awk '{print $1}')"

if [[ "${CURRENT_CHECKSUM}" != "${EXPECTED_CHECKSUM}" ]]; then
    echo "Checksum verification failed."
    exit 1
else
    echo "Checksum OK ✔"
fi

tar -xzvf "${TMP_DOWNLOAD_DIRECTORY}/dbeaver-ce-${LATEST_VERSION}-linux.gtk.$(uname -m).tar.gz" \
    -C "${HOME}/.local/share/dbeaver-ce" \
    --strip-components=1

#mv "${HOME}/.local/share/dbeaver-ce/dbeaver-ce.desktop" "${HOME}/.local/share/applications/dbeaver.desktop"
#sed -i "s|/usr/share|${HOME}/.local/share|g" "${HOME}/.local/share/applications/dbeaver.desktop"

tee "${HOME}/.local/share/applications/dbeaver.desktop" <<EOF
[Desktop Entry]
Version=1.0
Type=Application
Terminal=false
Name=dbeaver-ce
GenericName=Universal Database Manager
Comment=Universal Database Manager and SQL Client.
Path=${HOME}/.local/share/dbeaver-ce/
# GDK_BACKEND=x11
Exec=env NO_AT_BRIDGE=1 GDK_SCALE=1 GDK_DPI_SCALE=1 ${HOME}/.local/share/dbeaver-ce/dbeaver %U
Icon=${HOME}/.local/share/dbeaver-ce/dbeaver.png
Categories=IDE;Development
StartupWMClass=DBeaver
StartupNotify=true
Keywords=Database;SQL;IDE;JDBC;ODBC;MySQL;PostgreSQL;Oracle;DB2;MariaDB
MimeType=application/sql
EOF

echo "Dbeaver installed successfully!"
