#!/bin/bash
# webmenc <input_file> <profile>

_input=$1
[ -f $1 ] || exit

_profile=$2
[ "_profile" ] || exit

QUALITY["240"]="37"
QUALITY["360"]="36"
QUALITY["480"]="33"
QUALITY["720"]="32"
QUALITY["1080"]="31"

TILE["240"]="0 -threads 2"
TILE["360"]="1 -threads 4"
TILE["480"]="1 -threads 4"
TILE["720"]="2 -threads 8"
TILE["1080"]="2 -threads 8"

SPEED["240"]="1"
SPEED["360"]="1"
SPEED["480"]="1"
SPEED["720"]="2"
SPEED["1080"]="2"

[ "${QUALITY["$_profile"]}" ] || exit

_output=${_input%\.*}.webm

while [ -f $_output ]; do
    _output=${_input%\.*}_$((++_i)).webm
done

ffmpeg -i $_input -an -vf scale=-1:$_profile -c:v libvpx-vp9 \
  -b:v 0 -crf ${QUALITY["$_profile"]} \
  -tile-columns ${TILE["$_profile"]} \
  -pass 1 speed 4 \
  $_output && \
ffmpeg -i $_input -vf scale=-1:$_profile -c:v libvpx-vp9 \
  -b:v 0 -crf ${QUALITY["$_profile"]} \
  -tile-columns ${TILE["$_profile"]} \
  -pass 2 speed ${SPEED["$_profile"]} \
  -c:a libopus \
  -y \
  $_output
