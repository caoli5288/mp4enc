# MP4Encoder
This is a simple bash script convert media to mp4 format. About [noise reduce](http://blog.mengcraft.com/2016/think-in-x264-video-noise-reduce/).

## Depend
Put those bin file into your PATH folder.
- [FFmpeg](http://www.ffmpeg.org/)
- [Nero AAC Codec](http://www.nero.com/enu/company/about-nero/nero-aac-codec.php)
- [FAAC(optional)](http://www.audiocoding.com/faac.html)

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
  OPT=$(getopt -u -o ab:c:n:i:p:t:q:o:s: --long crf:,preset:,tune:,size -n 'mp4enc' -- $@)
  if (($? == 0)); then
    set -- ${OPT}
  else
    exit 1
  fi
  unset OPT
else
  echo 'Usage: mp4enc [option]... -i <input> [-o <output>]'
  echo '  -a           The audio stream will not be encoded(copy direct).'
  echo '  -b           The video bitrate value. Syntax like "1536k".'
  echo '  -c, --crf    The video CRF value. A float like 23(default).'
  echo '  -n           The video noise reduce. Valid rage 0-10000.'
  echo '  -p, --preset The video encoder preset. It can be ultrafast,'
  echo '               superfast, veryfast, faster, fast,'
  echo '               medium, slow, slower(default), veryslow and placebo.'
  echo '  -q           The audio target quality. A float like 0.3(default).'
  echo '  -s, --size   The video size. Syntax like "800x600".'
  echo '  -t, --tune   The video encoder tune. It can be film(default),'
  echo '               animation, grain, stillimage, psnr,'
  echo '               ssim, fastdecode, zerolatency and touhou.'
  echo ''
  echo 'The encoder will work on CRF mode if bitrate not set.'
  echo 'More info on https://github.com/caoli5288/mp4enc.'
  exit 2
fi

FFMPEG=$(which ffmpeg 2> /dev/null)
NERO_AAC=$(which neroAacEnc 2> /dev/null)
FAAC_AAC=$(which faac 2> /dev/null)

if [[ ! $FFMPEG ]]; then
  echo 'FFmpeg NOT found!'
  exit 3
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
    -n)
      NOISE=$2
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

if [[ ! $NERO_AAC ]]; then
  echo 'Nero AAC Encoder NOT found!'
  if [[ ! $FAAC_AAC ]]; then
    echo 'FAAC Encoder NOT found!'
    if [[ ! A_COPY ]]; then
      exit 4
    fi
  else
    echo 'FAAC Encoder was found!'
    USE_FAAC=TRUE
  fi
fi

if [[ ! $INPUT ]] || [ ! -f $INPUT ]; then
  echo 'You must specify a input file!'
  exit '3'
fi

STAMP=$(date +%s)

# Temp file clean up.
trap "rm -f .$STAMP.*" EXIT

# Encode video stream with ffmpeg(libx264).
if [[ $BITRATE ]]; then
  ffmpeg -i $INPUT -an ${SIZE:+-s $SIZE} ${NOISE:+-vf hqdn3d=$NOISE} -pass 1 -b $BITRATE -vcodec libx264 -passlogfile .$STAMP.log -tune ${TUNE:-'film'} .$STAMP.mp4 || exit 5
  ffmpeg -y -i $INPUT -an ${SIZE:+-s $SIZE} ${NOISE:+-vf hqdn3d=$NOISE} -pass 2 -b $BITRATE -vcodec libx264 -passlogfile .$STAMP.log -tune ${TUNE:-'film'} -preset ${PRESET:-'slower'} .$STAMP.mp4
else
  ffmpeg -i $INPUT -an ${SIZE:+-s $SIZE} ${NOISE:+-vf hqdn3d=$NOISE} -vcodec libx264 -crf ${CRF:-'23'} -preset ${PRESET:-'slower'} -tune ${TUNE:-'film'} .$STAMP.mp4 || exit 5
fi

# Encode audio stream with nero's aac encoder.
if [[ $A_COPY ]]; then
  ffmpeg -i $INPUT -vn -acodec copy .$STAMP.m4a
elif [[ $USE_FAAC ]] ;then
  ffmpeg -i $INPUT -vn -f wav - | faac -o .$STAMP.m4a -
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
