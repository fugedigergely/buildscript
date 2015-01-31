#!/bin/bash

# Version 1.0beta, Adapted for CyanogenMod 12.

# We don't allow scrollback buffer
echo -e '\0033\0143'
clear

# Import command line parameters
DEVICE="$1"
EXTRAS="$2"

if [ -z "$DEVICE" ]; then
       clear
       echo "You have to set what device are you building for! example: ./build.sh hallon kernel"
       exit
fi

if [ -z "$EXTRAS" ]; then
       clear
       echo "You have to set what are you building! example: ./build.sh hallon kernel"
       exit
fi

# Prepare output customization commands
red=$(tput setaf 1)             #  red
grn=$(tput setaf 2)             #  green
blu=$(tput setaf 4)             #  blue
cya=$(tput setaf 6)             #  cyan
txtbld=$(tput bold)             # Bold
bldred=${txtbld}$(tput setaf 1) #  red
bldgrn=${txtbld}$(tput setaf 2) #  green
bldblu=${txtbld}$(tput setaf 4) #  blue
bldcya=${txtbld}$(tput setaf 6) #  cyan
txtrst=$(tput sgr0)             # Reset

cd ~/android/system

echo -e "${bldblu}Adding ~/bin to path just in case if it's not there ${txtrst}";
export PATH="$HOME/bin:$PATH"

echo -e "${bldblu}Enabling ccache ${txtrst}";
export USE_CCACHE=1

echo -e "${bldblu}Setting ccache dir to ~/ccache ${txtrst}";
mkdir -p ~/ccache
export CCACHE_DIR=~/ccache
prebuilts/misc/linux-x86/ccache/ccache -M 50G

echo -e "${bldblu}Setting output dir to ~/out ${txtrst}";
export OUT_DIR_COMMON_BASE=~/out
clear

read -p "${bldgrn}Do you want to sync the latest changes? ${txtrst}? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
curl https://raw.githubusercontent.com/LegacyXperia/local_manifests/cm-12.0/semc.xml > ~/android/system/.repo/local_manifests/semc.xml
repo sync -j32
curl https://raw.githubusercontent.com/LegacyXperia/local_manifests/cm-12.0/updates.sh > ~/android/system/updates.sh
chmod a+x updates.sh
./updates.sh
fi

echo -e "${bldblu}Setting up the build environment ${txtrst}";
source build/envsetup.sh

echo -e "${bldblu}Lunching $DEVICE ${txtrst}";
breakfast $DEVICE
clear

read -p "${bldgrn}Do you want to clean the out folder? ${txtrst}? " -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
then
make clean
fi

# Get start time
res1=$(date +%s.%N)

echo -e "${cya}Building ${bldcya}CyanogenMod 12 ${cya}$EXTRAS for $DEVICE ${txtrst}";
echo -e "${bldgrn}Start time: $(date) ${txtrst}"
if [ "$EXTRAS" == "kernel" ]; then
        mka -j3 bootimage
fi
if [ "$EXTRAS" == "rom" ]; then
        brunch $DEVICE
fi

# Get elapsed time
res2=$(date +%s.%N)
echo -e "${bldgrn}Total time elapsed: ${txtrst}${grn}$(echo "($res2 - $res1) / 60"|bc ) minutes ($(echo "$res2 - $res1"|bc ) seconds)${txtrst}"

