#!/bin/bash

# Download wallpapers
# to get all linked images from a web page, use this javascript snippet in the browser console:
# let links = [];document.querySelectorAll('a').forEach((node)=>{links.push(node.href)});
# let images = [...new Set(links)].filter(href => /.*\.jpg$/g.test(href)).map(img => img.split('/').pop().replace('.jpg',''))
# console.log(images);

. ./colors.sh

USER=${USER:-$(whoami)}
WALLPAPER_DIR="/home/${USER}/Images/SimonStalenhag"

# Check if wallpaper directory exists
if [ ! -d "$WALLPAPER_DIR" ]; then
    logInfo "Creating wallpaper directory: $WALLPAPER_DIR"
    mkdir -p "$WALLPAPER_DIR"
    chown "$USER:$USER" "$WALLPAPER_DIR"
    chmod 755 "$WALLPAPER_DIR"
    DOWNLOAD_NEEDED=1
else
    logInfo "Wallpaper directory already exists, skipping downloads"
    DOWNLOAD_NEEDED=0
fi

if [ "$DOWNLOAD_NEEDED" -eq 1 ]; then
    logInfo "Starting wallpaper downloads..."

    logInfo "Downloading 'tales from the loop' wallpapers..."
    tftl_numbers=()
    for i in {1..46}; do
        if [ $i -ne 21 ]; then
            tftl_numbers+=($i)
        fi
    done

    for num in "${tftl_numbers[@]}"; do
        url="https://www.simonstalenhag.se/tftlbig/${num}.jpg"
        dest="$WALLPAPER_DIR/tftl_${num}.jpg"
        logInfo "Downloading $url"
        curl -o "$dest" "$url"
        chown "$USER:$USER" "$dest"
        chmod 755 "$dest"
    done

    # Download "things from the flood" wallpapers (range 4-55)
    logInfo "Downloading 'things from the flood' wallpapers..."
    tftf_numbers=()
    for i in {4..55}; do
        tftf_numbers+=($i)
    done

    for num in "${tftf_numbers[@]}"; do
        url="https://www.simonstalenhag.se/tftfbig/${num}.jpg"
        dest="$WALLPAPER_DIR/tftf_${num}.jpg"
        logInfo "Downloading $url"
        curl -o "$dest" "$url"
        chown "$USER:$USER" "$dest"
        chmod 755 "$dest"
    done

    # Download "swedish machines" wallpapers (range 1-46, exclude 19, with zero-padding)
    logInfo "Downloading 'swedish machines' wallpapers..."
    svema_numbers=()
    for i in {1..46}; do
        if [ $i -ne 19 ]; then
            svema_numbers+=($i)
        fi
    done

    for num in "${svema_numbers[@]}"; do
        leftpadindex=$(printf "%02d" $num)
        url="https://www.simonstalenhag.se/4k/svema_${leftpadindex}_big.jpg"
        dest="$WALLPAPER_DIR/svema_${leftpadindex}_big.jpg"
        logInfo "Downloading $url"
        curl -o "$dest" "$url"
        chown "$USER:$USER" "$dest"
        chmod 755 "$dest"
    done

    # Download more wallpapers (manual list)
    logInfo "Downloading additional wallpapers..."
    wallpaper_names=(
        # the labyrinth:
        "l_ash02_big"
        "l_fb_01_big"
        "l_fb_04_big"
        "l_fb_06_big"
        "l_fb_07_big"
        "l_fb_08_big"
        "l_fb_11_big"
        "l_ash03_big"
        "l_ash04_big"
        "l_ash05_big"
        "l_ash06_big"
        "l_garage01_big"
        "l_int01_big"
        "l_int02_big"
        "l_int03_big"
        "l_ash07_big"
        "l_ash08_big"
        "l_ash09_big"
        "l_ash10_big"
        "l_ash11_big"
        "l_int05_big"
        "l_ash12_big"
        "l_ash13_big"
        "l_int06_big"
        "l_ash14_big"
        "l_ash15_big"
        "l_ash16_big"
        "l_int07_5_big"
        "l_ash17_big"
        "l_fb_09_big"
        "l_fb_10_big"
        "l_fb_12_big"
        # the electric state:
        "by_dust01_2560"
        "by_dust02_2560"
        "by_border_2880"
        "by_ducks_2560"
        "by_warmachines5_1920"
        "by_warmachines7_1920"
        "by_upload1_2560"
        "by_burned_2560"
        "by_billboards2_2560"
        "by_on_ramp_2560"
        "by_billboards_2560"
        "by_waiters_2560"
        "by_mound_1920"
        "by_mules_1920"
        "by_warmachines1_2560"
        "by_warmachines3_1920"
        "by_mainservers1_1920"
        "by_mainservers2_2560"
        "by_cablers_1920"
        "by_wipers_1920"
        "by_renderfarm_1920"
        "by_upload2_2560"
        "by_themascot_1920"
        "by_memorial_1920"
        "by_nestingcliffs_2560"
        "by_belltowers_2880"
        "by_hello_1920"
        "by_gathering3_2880"
        "by_procession_1920"
        "by_gathering2_2560"
        "by_sculptures_1920"
        "by_housevisit_2560"
        "by_conception_1920"
        "by_localservers_2560"
        "by_localservers2_2560"
        "by_roadwork_1920"
        "by_warmachines4_1920"
        "by_warmachines8_1920"
        "by_warmachines2_2560"
        "by_crossing_2560"
        "by_home_arrival_2560"
        "by_home_2560"
        "by_home2_2560"
        "by_home3_2560"
        "by_home4_2560"
        "by_home5_1920"
        "by_home6_2560"
        "by_scavengers_1920"
    )

    for name in "${wallpaper_names[@]}"; do
        url="https://www.simonstalenhag.se/bilderbig/${name}.jpg"
        dest="$WALLPAPER_DIR/${name}.jpg"
        logInfo "Downloading $url"
        curl -o "$dest" "$url"
        chown "$USER:$USER" "$dest"
        chmod 755 "$dest"
    done

    printSuccess "All wallpapers downloaded successfully!"
else
    logInfo "Wallpaper directory already exists, no downloads performed."
fi
