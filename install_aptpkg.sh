#!/bin/bash
#WU,Qihang <wu.qihang@hotmail.com>#
#Last modified: 13 Dec 2018 11:54:07 AM#

# ===============================================
# FUNCTIONS
# -----------------------------------------------
# Notifications
# ----------------------
color_print() {
    printf '\033[0;31m%s\033[0m\n' "$1"
}
warn() {
    color_print "$1" >&2
}
info() {
    printf "\r  [ \033[00;34m..\033[0m ] $1\n"
}
user() {
    printf "\r  [ \033[0;33m??\033[0m ] $1\n"
}
success() {
    printf "\r\033[2K  [ \033[00;32mOK\033[0m ] $1\n"
}
fail() {
    printf "\r\033[2K  [\033[0;31mFAIL\033[0m] $1\n"
    echo ''
    exit 1
}

# ----------------------
# Installations
# ----------------------
# commands
instcmd='apt-get install -y'
addrepo='add-apt-repository -y ppa:'
aptupd='apt-get update'

install_pkgs() {
    # provide an array of package names
    # and install these packages silently
    arr=("$@")
    for pkg in ${arr[@]}
    do
        info "Installing $pkg ..."

        # check if we need to add ppa key
        local ppakey=${pkgppa[$pkg]}
        if [ ! -z $ppakey ]
        then
            info "Adding ppa for $pkg from source $ppakey ..."
            $addrepo$ppakey >/dev/null 2>&1
            if [ $? -eq 0 ]
            then 
                $aptupd >/dev/null 2>&1
                success "Key $ppakey for $pkg successfully added"
            else
                warn "Fail to add $ppakey for $pkg as a ppa key..."
            fi
        fi

        # install package
        $instcmd $pkg > /dev/null
        if [ $? -eq 0 ]
        then 
            success "$pkg successfully installed"
        else
            warn "Installation for $pkg is not successful"
        fi
    done
}


# ===============================================
# PARAMETERS
# -----------------------------------------------
# packages
pkg_compiler=(python python3 gcc g++ gfortran julia octave)
pkg_devtools=(build-essential cscope ctags curl git paraview\
    ipython python-dev python-pip python3-dev python3-pip \
    tmux xsel valgrind vim vim-gtk)
pkg_document=(okular texlive-full)
pkg_input=(fcitx fcitx-googlepinyin im-config)
pkg_media=(inkscape vlc)
pkg_network=(aria2 geary)
pkg_systools=(grub-customizer htop screenfetch lightdm-gtk-greeter-settings ppa-purge ubuntu-cleaner)
pkg_utils=(indicator-weather xpad)

pkg_classes=(pkg_compiler pkg_devtools pkg_document pkg_input pkg_media pkg_network pkg_systools pkg_utils)

# packages that require ppa key
declare -A pkgppa
pkgppa=( \
    ["grub-customizer"]="danielrichter2007/grub-customizer" \
    ["indicator-weather"]="kasra-mp/ubuntu-indicator-weather" \
    ["octave"]="octave/stable" \
    ["ubuntu-cleaner"]="gerardpuig/ppa" \
    )

# ===============================================
# MAIN
# -----------------------------------------------
# debian fontends throw unnecessary errors
export DEBIAN_FRONTEND="noninteractive"

# make sure run by root
if [ $(whoami) != 'root' ]
then
    fail "Must be root to run $0"
    exit 1;
fi

# start installation process
install_pkgs "${pkg_compiler[@]}"
install_pkgs "${pkg_devtools[@]}"
install_pkgs "${pkg_document[@]}"
install_pkgs "${pkg_input[@]}"
install_pkgs "${pkg_media[@]}"
install_pkgs "${pkg_network[@]}"
install_pkgs "${pkg_systools[@]}"
install_pkgs "${pkg_utils[@]}"

color_print "Package installation completed!"
