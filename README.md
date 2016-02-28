# MP4Encoder
This is a simple bash script convert media to mp4 format. About [noise reduce](http://blog.mengcraft.com/2016/think-in-x264-video-noise-reduce/).

## Depend
Put those bin file into your PATH folder.
- [FFmpeg](http://www.ffmpeg.org/)
- [Nero AAC Codec](http://www.nero.com/enu/company/about-nero/nero-aac-codec.php)

## Usage
```
$ mp4enc [option]... -i <input> [-o <output>]
    -a           The audio stream will not be encoded(copy direct).
    -b           The video bitrate value. Syntax like "1536k".
    -c, --crf    The video CRF value. A float like 24(default).
        --codec  What library used to encode vedio(default libx264).
    -n           The video noise reduce. Valid rage 0-10000.
    -p, --preset The video encoder preset. It can be ultrafast,
                 superfast, veryfast, faster, fast,
                 medium, slow, slower,
                 veryslow(default) and placebo.
    -q           The audio target quality(default 0.3).
    -s, --size   The video size. Syntax like "800x600".
    -t, --tune   The video encoder tune. It can be film, animation,
                 grain, stillimage, psnr, ssim, fastdecode,
                 zerolatency and touhou(default none).
        --test   Test the first 30s stream(s).

The encoder will work on CRF mode if bitrate not set.
More info on https://github.com/caoli5288/mp4enc.
```
