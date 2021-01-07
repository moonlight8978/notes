#### video to gif

```bash
# Speed up video
ffmpeg -ss 00:15:00.000 -t 27 -i input.mp4 -filter:v "setpts=PTS/1.5" output.mp4
# Convert to GIF
ffmpeg -ss 00:15:00.000 -t 27 -i output.mp4 -pix_fmt pal8 -r 10 output.gif
# Optimize GIF
convert -layers Optimize output.gif output_optimized.gif
```

```bash
ffmpeg -ss 00:00:10.000 -i output.mp4 -vf "fps=10,scale=320:-1:flags=lanczos" -c:v pam -f image2pipe - | convert -delay 10 - -loop 0 -layers optimize output.gif
```
