#!/bin/bash
#WU,Qihang <wu.qihang@hotmail.com>#
#Last modified: 25 Jan 2019 01:02:52 PM#

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
updcmd='apt-get update'
rmcmd='apt-get purge -y'
upgcmd='apt-get upgrade -y'
autormcmd='apt-get autoremove -y'
addrepo='add-apt-repository -y ppa:'
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
                $updcmd >/dev/null 2>&1
                success "Key $ppakey for $pkg successfully added"
            else
                warn "Fail to add $ppakey for $pkg as a ppa key!"
            fi
        fi

        # install package
        $instcmd $pkg > /dev/null
        if [ $? -eq 0 ]
        then
            success "$pkg successfully installed"
        else
            warn "Installation for $pkg failed!"
        fi
    done
}

rm_pkgs() {
    arr=("$@")
    for pkg in ${arr[@]}
    do
        which $pkg
        if [ $? -eq 0 ]; then
            info "Removing $pkg..."
            $rmcmd $pkg 1 > /dev/null
        fi
    done
    
}


# ===============================================
# PARAMETERS
# -----------------------------------------------
# packages to install
pkg_compiler=(python python3 gcc g++ gfortran julia octave)
pkg_devtools=(ack-grep build-essential cscope ctags curl git paraview\
    ipython python-dev python-pip python3-dev python3-pip \
    tmux xsel valgrind vim vim-gtk)
pkg_document=(okular okular-extra-backends zathura xdotool texlive-full)
pkg_input=(fcitx fcitx-googlepinyin im-config)
pkg_media=(inkscape pavucontrol vlc mpv)
pkg_network=(aria2 geary)
pkg_systools=(grub-customizer htop screenfetch lightdm-gtk-greeter-settings ppa-purge ubuntu-cleaner)
pkg_utils=(go-for-it indicator-weather xpad)

# packages to remove
pkgrm=(firefox gnome-games-common gbrainy thunderbird)

# packages that require ppa key
declare -A pkgppa
pkgppa=( \
    ["go-for-it"]="mank319/go-for-it" \
    ["grub-customizer"]="danielrichter2007/grub-customizer" \
    ["indicator-weather"]="kasra-mp/ubuntu-indicator-weather" \
    ["octave"]="octave/stable" \
    ["ubuntu-cleaner"]="gerardpuig/ppa" \
    ["vim"]="jonathonf/vim"
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

# upgrade
color_print "Running upgrade for all packages..."
$updcmd
$upgcmd

# installing packages
color_print "Install user-defined packages..."
install_pkgs "${pkg_compiler[@]}"
install_pkgs "${pkg_devtools[@]}"
install_pkgs "${pkg_document[@]}"
install_pkgs "${pkg_input[@]}"
install_pkgs "${pkg_media[@]}"
install_pkgs "${pkg_network[@]}"
install_pkgs "${pkg_systools[@]}"
install_pkgs "${pkg_utils[@]}"

# removing some packages
color_print "Removing default packages..."
rm_pkgs "${pkgrm[@]}"
$autormcmd

color_print "Package configuration completed!"
