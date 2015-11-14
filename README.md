# MP4Encoder
This is a simple bash script convert media to mp4 format.

## Depend
Put those bin file into your PATH folder.
- [FFmpeg](http://www.ffmpeg.org/)
- [Nero AAC Codec](http://www.nero.com/enu/company/about-nero/nero-aac-codec.php)

## Example
- ./mp4enc -b 1500k -i mov.avi
  - Output file named `mov.mp4`. With 1500k bitrate video.
- ./mp4enc -c 21 -i mov.avi -o mov.mkv
  - Output file named `mov.mkv`.
## Usage
All line here. Put it into a file and make it executable.
```Bash
#!/bin/bash 

if [[ $@ ]]; then
  OPT=$(getopt -u -o ab:c:i:p:t:q:o:s: --long crf:,preset:,tune:,size -n 'mp4enc' -- $@)
  if (($? == 0)); then
    set -- ${OPT}
  else
    exit 1
  fi
  unset OPT
else
  echo 'Usage: ./mp4enc [option]... -i <input> [-o <output>]'
  echo '  -a                The audio stream will not be encoded(copy).'
  echo '  -b                The video bitrate value.'
  echo '  -c, --crf         The video CRF value. Default 23.'
  echo '  -p, --preset      The video encoder preset. Default "slower".'
  echo '  -q                The audio target quality. Default 0.3.'
  echo '  -s, --size        The video size. Default original.'
  echo '  -t, --tune        The video encoder tune. Default "psnr".'
  echo ''
  echo 'The encoder will work on CRF mode if bitrate not set.'
  echo 'More info on https://github.com/caoli5288/mp4enc.'
  exit '2'
fi

while [[ $@ ]]; do
  case $1 in
    -a)
      A_COPY=YES
      shift 1
      ;;
    -o)
      OUTPUT=$2
      shift 2
      ;;
    -q)
      QUALITY=$2
      shift 2
      ;;
    -c|--crf)
      CRF=$2
      shift 2
      ;;
    -b)
      BITRATE=$2
      shift 2
      ;;
    -i)
      INPUT=$2
      shift 2
      ;;
    -p|--preset)
      PRESET=$2
      shift 2
      ;;
    -s|--size)
      SIZE=$2
      shift 2
      ;;
    -t|--tune)
      TUNE=$2
      shift 2
      ;;
    --)
      shift 1
      ;;
    * )
      shift 1
      ;;
  esac
done

if [[ ! $INPUT ]] || [ ! -f $INPUT ]; then
  echo 'You must specify a input file!'
  exit '3'
fi

STAMP=$(date +%s)

# Temp file clean up.
trap "rm -f .$STAMP.*" EXIT

# Encode video stream with ffmpeg(libx264).
if [[ $BITRATE ]]; then
  ffmpeg -i $INPUT -an ${SIZE:+-s $SIZE} -pass 1 -b $BITRATE -vcodec libx264 -passlogfile .$STAMP.log -tune ${TUNE:-'psnr'} .$STAMP.mp4 || exit 4
  ffmpeg -y -i $INPUT -an ${SIZE:+-s $SIZE} -pass 2 -b $BITRATE -vcodec libx264 -passlogfile .$STAMP.log -tune ${TUNE:-'psnr'} -preset ${PRESET:-'slower'} .$STAMP.mp4
else
  ffmpeg -i $INPUT -an ${SIZE:+-s $SIZE} -vcodec libx264 -crf ${CRF:-'23'} -preset ${PRESET:-'slower'} -tune ${TUNE:-'psnr'} .$STAMP.mp4 || exit 4
fi

# Encode audio stream with nero's aac encoder.
if [[ $A_COPY ]]; then
  ffmpeg -i $INPUT -vn -acodec copy .$STAMP.m4a
else
  ffmpeg -i $INPUT -vn -f wav - | neroAacEnc -q ${QUALITY:-'0.3'} -ignorelength -if - -of .$STAMP.m4a
fi

# Mix video and audio stream(s).
if [ -f .$STAMP.m4a ]; then
  ffmpeg -y -i .$STAMP.mp4 -i .$STAMP.m4a -vcodec copy -acodec copy ${OUTPUT:-${INPUT%\.*}.mp4}
else
  ffmpeg -y -i .$STAMP.mp4 -vcodec copy ${OUTPUT:-${INPUT%\.*}.mp4}
fi
```
