#!/bin/bash

for dir in */; do
    dir=${dir%/}
    if [ $dir = esp32 ]; then
        TOOLCHAIN="xtensa-esp32-elf"
    elif [ $dir = esp32s2 ]; then
        TOOLCHAIN="xtensa-esp32s2-elf"
    elif [ $dir = esp32s3 ]; then
        TOOLCHAIN="xtensa-esp32s3-elf"
    else
        TOOLCHAIN="riscv32-esp-elf"
    fi
    if [ -d "$dir" ]; then
        cd "$dir" || continue

        for lib in *.a; do
            echo $dir/$lib
            if [ "$lib" = "librtc.a" ]; then
                git status "$lib" | grep -E "modified|new file" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo "$dir/$lib fixed"
                    $TOOLCHAIN-objcopy --redefine-sym ets_printf=rtc_printf "$lib"
                fi
                continue
            fi

            git status "$lib" | grep -E "modified|new file" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo "$dir/$lib fixed"
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf "$lib"
            fi
        done
        cd ..
    else
        echo "$dir does not exist"
    fi
done
