#!/bin/bash
chip_list=(esp32 esp32s2 esp32c3 esp32s3 esp32h2 esp32h4 esp32c2 esp32c6 esp32c5 esp32c61)

for dir in "${chip_list[@]}"; do
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
        cd $dir

        if [ $dir = esp32 ]; then
            git status librtc.a | grep "modified\|new file" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo $dir/librtc.a fixed
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=rtc_printf librtc.a
            fi
        elif [ $dir != esp32s2 ]; then
            git status libbtbb.a | grep "modified\|new file" >/dev/null 2>&1
            if [ $? -eq 0 ]; then
                echo $dir/libbtbb.a fixed
                $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf libbtbb.a
            fi
        fi
        git status libphy.a | grep "modified\|new file" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo $dir/libphy.a fixed
            $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf libphy.a
        fi
        case "$dir" in
            esp32c3|esp32s3|esp32c2|esp32c6|esp32c5|esp32c61|esp32s2|esp32h2|esp32h4|esp32)
                if [ $dir != esp32s2 ]; then
                    git status libbttestmode.a | grep "modified\|new file" >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo $dir/libbttestmode.a fixed
                        $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf libbttestmode.a
                    fi
                fi
                if [ $dir != esp32 ]; then
                    git status librfate.a | grep "modified\|new file" >/dev/null 2>&1
                    if [ $? -eq 0 ]; then
                        echo $dir/librfate.a fixed
                        $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf librfate.a
                    fi
                fi
                git status librftest.a | grep "modified\|new file" >/dev/null 2>&1
                if [ $? -eq 0 ]; then
                    echo $dir/librftest.a fixed
                    $TOOLCHAIN-objcopy --redefine-sym ets_printf=phy_printf librftest.a
                fi
        esac
        cd ..
    else
        echo "$dir does not exist"
    fi
done;
