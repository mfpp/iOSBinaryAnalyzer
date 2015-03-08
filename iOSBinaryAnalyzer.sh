#!/bin/bash

if [[ "$1" == "" ]]
then
        echo " Usage: iOSBinaryAnalyzer.sh <binary>"
        exit 1
fi

if [[ ! -f "$1" ]]
then
        echo " Error: file does not exist"
        exit 1
fi

type otool &>/dev/null

if [[ "$?" -ne "0" ]]
then
        echo " Error: otool is not installed. Using Cydia, otool can be found in the following package: Darwin CC Tools"
        exit 1
fi

echo '   _ ____  ____  ___  _                      ___             __                '
echo '  (_) __ \/ __/ / _ )(_)__  ___ _______ __  / _ | ___  ___ _/ /_ _____ ___ ____'
echo ' / / /_/ /\ \  / _  / / _ \/ _ `/ __/ // / / __ |/ _ \/ _ `/ / // /_ // -_) __/'
echo '/_/\____/___/ /____/_/_//_/\_,_/_/  \_, / /_/ |_/_//_/\_,_/_/\_, //__/\__/_/   '
echo '                                   /___/                    /___/              '

echo ""
echo "==[ Target ]==================================================================="
echo ""
echo " $1"

entitlements=$(sed -n "/<dict>/,/<\/dict>/p" "$1" | sed -n "/<array>/,/<\/array>/p" | grep string | cut -d">" -f2 | cut -d"<" -f1 | sort -u)

echo ""
echo "==[ Entitlements ]============================================================="
echo ""
echo " $entitlements"

echo ""
echo "==[ Binary Analysis Results ]=================================================="

hds_n=$(otool -hV "$1" | grep -c "Mach header")

if [[ $hds_n -gt 1 ]]
then
        archs=$(otool -hV "$1" | grep architecture | cut -d"(" -f2 | cut -d" " -f2 | sed 's/)://')
        echo ""
        echo " This is a Fat binary with $hds_n architectures:" $archs
else
        archs="all"
fi

details=""

for a in $archs
do
        if [[ $hds_n -gt 1 ]]
        then
                echo ""
                echo "@ $a"
        fi

        echo ""

        encrypt=$(otool -l -arch $a "$1" | grep cryptid)

        if [[ "$(echo $encrypt | sed 's/ //g')" == "cryptid1" ]]
        then
                echo " Encrypted?                                    Yes"
        else
                echo " Encrypted?                                    No"
        fi
        
        pie=$(otool -hV -arch $a "$1" | grep PIE)

        if [[ "$pie" == "" ]]
        then
                echo " PIE enabled?                                  No"
        else
                echo " PIE enabled?                                  Yes"
        fi

        canaries=$(otool -IV -arch $a "$1" | grep stack)

        if [[ "$canaries" == "" ]]
        then
                echo " Stack Smashing Protection enabled?            No"
        else
                echo " Stack Smashing Protection enabled?            Yes"
        fi

        arc=$(otool -IV -arch $a "$1" | grep _objc_release)

        if [[ "$arc" == "" ]]
        then
                echo " Automatic Reference Counting (ARC) enabled?   No"
        else
                echo " Automatic Reference Counting (ARC) enabled?   Yes"
        fi

        details="$details otool -l -arch $a '$1' | grep cryptid\n$encrypt\n otool -hV -arch $a '$1' | grep PIE\n$pie\n otool -IV -arch $a '$1' | grep stack\n$canaries\n otool -IV -arch $a '$1' | grep _objc_release\n$arc\n"
done

echo ""
echo "==[ Details ]=================================================================="
echo ""
echo -e "$details"
