#!/bin/bash

mkdir -p dist
mkdir -p originals

# Colored Output
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
BLUE=$(tput setaf 4)
RESET=$(tput sgr0)
BOLD=$(tput bold)

# Image sizes, feel free to change
declare -a sizes=("1500x750" "1200x600" "1000x500" "840x600" "420x600")

# Count images in root directory
numFiles=( *.{png,jpeg,jpg} )
progress=0

# Banner
clear
echo -e "${BLUE}===========================================${RESET}"
echo -e "${BOLD}${WHITE}Image Resizer${RESET}\nBy: (https://utilidev.com)"
echo -e "${BLUE}===========================================${RESET}"

# Loop through all images in current folder
for image in `ls *.{png,jpeg,jpg} -R 2>/dev/null`; do

    # Copy original to dist and originals folder
    cp $image "dist/${image%.*}-original.jpg"
    cp $image originals/$image

    # Increment Progress
    (( progress++ ))
    echo -e "\n${BLUE}$progress/${#numFiles[@]}${RESET}${BOLD}\t\t$image${RESET}"

    # Compress image
    /usr/local/opt/mozjpeg/bin/cjpeg -quality 90 -outfile "compress.jpg" $image && mv "compress.jpg" $image
    echo -e "${GREEN}Compressed \t$image${RESET}"

    # Generate sizes
    for size in "${sizes[@]}"; do
        if [[ ! -f "dist/${image%.*}-$size.jpg" ]]; then

            # Scales image without change in aspect ratio
            convert ${image} -resize "$size" "dist/${image%.*}-scaled-$size.jpg"
            echo -e "${GREEN}Scaled  \t$image to\t($size)${RESET}"

            # Crops image form center to exact size
            convert ${image} -resize "$size^" -gravity center -crop $size+0+0 +repage "dist/${image%.*}-$size.jpg"
            echo -e "${GREEN}Cropped \t$image to\t($size)${RESET}"
        fi
    done

    # Remove from root directory
    rm $image
done
