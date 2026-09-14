#!/bin/bash

bios=logo

function goto
{
    label=$1
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

rm -f $bios.obj 2>/dev/null
rm -f $bios.lst 2>/dev/null
rm -f $bios.bin 2>/dev/null

chmod +x linux/*

echo "*******************************************************************************"
echo "Assembling BIOS"
echo "*******************************************************************************"
linux/wasm -zcm=tasm -d1 -e=1 -fe=/dev/null -fo=$bios.obj $bios.asm
if [ $? = "1" ]; then goto errasm; fi
if [ ! -e "$bios.obj" ]; then goto errasm; fi

echo
echo "*******************************************************************************"
echo "Generating Listing"
echo "*******************************************************************************"
linux/wdis -l=$bios.lst -s=$bios.asm $bios.obj
if [ $? = "1" ]; then goto errlist; fi
if [ ! -e "$bios.lst" ]; then goto errlist; fi
echo Ok

echo
echo "*******************************************************************************"
echo "Linking BIOS"
echo "*******************************************************************************"
linux/wlink format raw bin name $bios.bin file $bios.obj
rm -f $bios.obj 2>/dev/null
if [ ! -e "$bios.bin" ]; then goto errlink; fi

linux/rompad < "$bios.bin" > "$bios.rom"

echo "*******************************************************************************"
echo "SUCCESS!: BIOS successfully built"
echo "*******************************************************************************"
goto end

errasm:
echo
echo
echo "*******************************************************************************"
echo "ERROR: Error assembling BIOS"
echo "*******************************************************************************"
goto end

errlist:
echo
echo
echo "*******************************************************************************"
echo "ERROR: Error generating listing file"
echo "*******************************************************************************"
goto end

errlink:
echo
echo "*******************************************************************************"
echo "ERROR: Error linking BIOS"
echo "*******************************************************************************"
goto end

end:
rm -f $bios.obj 2>/dev/null
rm -f $bios.exe 2>/dev/null

bios=

