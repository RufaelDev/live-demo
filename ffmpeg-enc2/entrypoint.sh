#!/bin/sh

# set env vars to defaults if not already set
export FRAME_RATE="${FRAME_RATE:-25}"
export GOP_LENGTH="${GOP_LENGTH:-${FRAME_RATE}}"
export AUDIO_FRAG_DUR_MICROS="${AUDIO_FRAG_DUR_MICROS:-1920000}"

if [ "${FRAME_RATE}" = "30000/1001" -o "${FRAME_RATE}" = "60000/1001" ]; then
  echo "drop frame"
  export FRAME_SEP="."
else
  export FRAME_SEP=":"
fi

export LOGO_OVERLAY="${LOGO_OVERLAY-https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png}"

if [ -n "${LOGO_OVERLAY}" ]; then
  export LOGO_OVERLAY="-i ${LOGO_OVERLAY}"
  export OVERLAY_FILTER=", overlay=eval=init:x=W-15-w:y=15"
fi

# validate required variables are set
if [ -z "${PUB_POINT_URI}" ]; then
  echo >&2 "Error: PUB_POINT_URI environment variable is required but not set."
  exit 1
fi

timecode=$(date +%H\\:%M\\:%S).00
PUB_POINT=${PUB_POINT_URI}

set -x
exec ffmpeg -re \
-f lavfi \
-i smptehdbars=size=1280x720 \
-i "https://raw.githubusercontent.com/unifiedstreaming/live-demo/master/ffmpeg/usp_logo_white.png" \
-filter_complex \
"[v]drawbox=y=25: x=iw/2-iw/7: c=0x00000000@1: w=iw/3.5: h=36: t=fill, \
drawtext=text='DASH-IF Live Media Ingest Protocol': fontsize=32: x=(w-text_w)/2: y=75: fontsize=32: fontcolor=white,\
drawtext=text='video-576p25-500k': fontsize=32: x=(w-text_w)/2: y=125: fontsize=32: fontcolor=white, \
drawtext=timecode_rate=${FRAME_RATE}: timecode='$(date -u +%H\\:%M\\:%S)\\${FRAME_SEP}$(($(date +%3N)/$((1000/$FRAME_RATE))))': tc24hmax=1: fontsize=32: x=(w-tw)/2+tw/2: y=30: fontcolor=white, \
drawtext=text='%{gmtime\:%Y-%m-%d}\ ': fontsize=32: x=(w-tw)/2-tw/2: y=30: fontcolor=white[v+tc]; \
[v+tc][1]overlay=eval=init:x=W-15-w:y=15[vid]" \
-map "[vid]" -s 1024x576 -c:v libx264 -b:v 500k -profile:v main -preset ultrafast -tune zerolatency \
-g $GOP_LENGTH \
-r $FRAME_RATE \
-keyint_min $GOP_LENGTH \
-fflags +genpts \
-movflags +frag_keyframe+empty_moov+separate_moof+default_base_moof \
-video_track_timescale 10000000 \
-ism_offset $(($(date +%s)*10000000)) \
-f mp4 "$PUB_POINT/Streams(video-576p25-500k.cmfv)" 