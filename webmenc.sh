#!/bin/bash

_input=$1
[ -f $1 ] || exit

_profile=$2
[ "_profile" ] || exit

BITRATE["240"]="150k -minrate 75k -maxrate 218k"
BITRATE["360"]="276k -minrate 138k -maxrate 400k"
BITRATE["480"]="750k -minrate 375k -maxrate 1088k"
BITRATE["720"]="1024k -minrate 512k -maxrate 1485k"
BITRATE["1080"]="1800k -minrate 900k -maxrate 2610k"

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

[ "$3" ] && _bitrate=${BITRATE["$_profile"]} || _bitrate=0

_output=${_input%\.*}.webm

while [ -f "$_output" ]; do
    _output=${_input%\.*}_$((++_i)).webm
done

ls ffmpeg2pass*.log || ffmpeg -i "$_input" -an -vf scale=-1:$_profile -c:v libvpx-vp9 \
  -b:v $_bitrate -crf ${QUALITY["$_profile"]} \
  -tile-columns ${TILE["$_profile"]} \
  -pass 1 -speed 4 \
  "$_output" || rm -f ffmpeg2pass*.log

ls ffmpeg2pass*.log && ffmpeg -i "$_input" -vf scale=-1:$_profile -c:v libvpx-vp9 \
  -b:v $_bitrate -crf ${QUALITY["$_profile"]} \
  -tile-columns ${TILE["$_profile"]} \
  -pass 2 -speed ${SPEED["$_profile"]} \
  -c:a libopus \
  -y \
  "$_output" && \
rm -f ffmpeg2pass*.log
