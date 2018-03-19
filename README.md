# MP4Encoder
This is a simple bash script convert media to mp4 format use [FFmpeg](http://www.ffmpeg.org/). About [noise reduce](http://blog.mengcraft.com/2016/think-in-x264-video-noise-reduce/).

## Usage
```
$ ./mp4enc
mp4enc [option]... -i <input> [-o <output>]

OPTION
    -a    The audio stream will be copy direct.
    -e    The encode. A str like libx265(default).
    -f    The frame rate (Hz value).
    -c    The video CRF value. A float like 23(default).
    -n    The video noise reduce. Valid rage 0-10000.
    -p    The video preset. A str like slow(default).
    -r    The video size. Syntax like "800x600".
    -t    The video encoder tune. A str like $TUNE(default).```
```
