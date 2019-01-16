#!/bin/bash
#WU,Qihang <wu.qihang@hotmail.com>#
#Last modified: 13 Dec 2018 02:03:56 PM#

clone="git clone"

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
