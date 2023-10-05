#!/usr/bin/env bash
set -e

pre_pro=(wget unzip tar pip3 gpg2 gcc)
for prog in "${pre_pro[@]}"; do
    if ! hash "${prog}" &>/dev/null; then
        echo "${prog}" not Installed
        exit 1
    fi
done

TEMP_DOWNLOAD_PATH="$HOME/.tmp/userapps"
SOURCE_PACKAGE_PATH="$HOME/.local/src"
PATH_TO_LOCAL_PREFX="$HOME/.local"

mkdir -p "$TEMP_DOWNLOAD_PATH" "$SOURCE_PACKAGE_PATH" "$PATH_TO_LOCAL_PREFX/share/applications"

NCURSES_VERSION=6.3
ZSH_VERSION=5.8

unset NCURSES_DOWNLOAD_URL
unset ZSH_DOWNLOAD_URL

if [[ "$(uname -m)" == 'x86_64' ]]; then
    NCURSES_DOWNLOAD_URL="https://ftp.gnu.org/pub/gnu/ncurses/ncurses-$NCURSES_VERSION.tar.gz"
    ZSH_DOWNLOAD_URL="https://onboardcloud.dl.sourceforge.net/project/zsh/zsh/$ZSH_VERSION/zsh-$ZSH_VERSION.tar.xz"
fi

echo ""
read -r -p "Enter \"YES\" to install ncurses $NCURSES_VERSION (Press any other key to Skip*) : " install_ncurses
echo ""
read -r -p "Enter \"YES\" to install zsh $ZSH_VERSION (Press any other key to Skip*) : " install_zsh
echo ""

if [[ "$install_ncurses" == "YES" ]]; then
    echo "# Ncurses Install Start"

    rm -rf "$SOURCE_PACKAGE_PATH/ncurses"
    mkdir -p "$SOURCE_PACKAGE_PATH/ncurses"

    export CXXFLAGS=' -fPIC'
    export CFLAGS=' -fPIC'

    if [ ! -f "$TEMP_DOWNLOAD_PATH/ncurses-${NCURSES_VERSION}.linux.tar.gz" ]; then
        wget --no-check-certificate "${NCURSES_DOWNLOAD_URL}" -O "$TEMP_DOWNLOAD_PATH/ncurses-${NCURSES_VERSION}.linux.tar.gz"
    fi

    tar -zxf "$TEMP_DOWNLOAD_PATH/ncurses-${NCURSES_VERSION}.linux.tar.gz" -C "$SOURCE_PACKAGE_PATH/ncurses" --strip-components 1

    cd "$SOURCE_PACKAGE_PATH/ncurses"
    "./configure" --prefix="$PATH_TO_LOCAL_PREFX" --enable-shared --with-shared --without-debug --enable-widec
    cd progs
    ./capconvert
    cd ..
    make
    make install
    unset CXXFLAGS
    unset CFLAGS
    source "$HOME/.bashrc"
    echo "# Ncurses Install end"
fi

if [[ "$install_zsh" == "YES" ]]; then
    echo "# ZSH Install Start"

    rm -rf "$SOURCE_PACKAGE_PATH/zsh"
    mkdir -p "$SOURCE_PACKAGE_PATH/zsh"

    if [ ! -f "$TEMP_DOWNLOAD_PATH/zsh-${ZSH_VERSION}.linux.tar.xz" ]; then
        wget --no-check-certificate "${ZSH_DOWNLOAD_URL}" -O "$TEMP_DOWNLOAD_PATH/zsh-${ZSH_VERSION}.linux.tar.xz"
    fi

    tar -xf "$TEMP_DOWNLOAD_PATH/zsh-${ZSH_VERSION}.linux.tar.xz" -C "$SOURCE_PACKAGE_PATH/zsh" --strip-components 1

    cd "$SOURCE_PACKAGE_PATH/zsh"

    export CFLAGS=-I$HOME/.local/include
    export CPPFLAGS="-I$HOME/.local/include" LDFLAGS="-L$HOME/.local/lib"

    "./configure" --prefix="$PATH_TO_LOCAL_PREFX"
    make
    make install

    unset CFLAGS
    unset CPPFLAGS

    echo "# ZSH Install end"
fi
