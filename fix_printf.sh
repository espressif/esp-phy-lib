#!/bin/bash
for dir in esp32 esp32s2 esp32c3 esp32s3 esp32h2 esp32c2; do
    if [ $dir = esp32 ]; then
        TOOLCHAIN="xtensa-esp32-elf"
    elif [ $dir = esp32s2 ]; then
        TOOLCHAIN="xtensa-esp32s2-elf"
    elif [ $dir = esp32c3 ]; then
        TOOLCHAIN="riscv32-esp-elf"
    elif [ $dir = esp32s3 ]; then
        TOOLCHAIN="xtensa-esp32s3-elf"
    elif [ $dir = esp32h2 ]; then
        TOOLCHAIN="riscv32-esp-elf"
    elif [ $dir = esp32c2 ]; then
        TOOLCHAIN="riscv32-esp-elf"
    else
        echo "$dir does not exist"
    fi
    if [ -d "$dir" ]; then
        cd $dir

        if [ $dir = esp32 ]; then
            git status librtc.a | grep "modified" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo $dir/librtc.a fixed
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=rtc_printf librtc.a
            fi
        elif [ $dir = esp32h2 ]; then
            for subdir in rev1 rev2 ; do
                cd $subdir
                git status libbtbb.a | grep "modified" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo $dir/libbtbb.a fixed
                    $TOOLCHAIN-objcopy --redefine-sym ets_printf=rtc_printf libbtbb.a
                fi
                git status libphy.a | grep "modified" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo $dir/libphy.a fixed
                    $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf libphy.a
                fi
                cd ..
            done
        elif [ $dir != esp32s2 ]; then
            git status libbtbb.a | grep "modified" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo $dir/libbtbb.a fixed
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=rtc_printf libbtbb.a
            fi
        fi
        if [ $dir != esp32h2 ]; then
            git status libphy.a | grep "modified" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo $dir/libphy.a fixed
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf libphy.a
            fi
        fi

        cd ..
    else
        echo "$dir does not exist"
    fi
done;
