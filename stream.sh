#!/bin/bash
# Script for live HLS streaming lossy audio as AAC and/or archiving lossless audio as FLAC  

# Pre-requisite
# s3fs/blobfuse file system at $RAWFS with appropriate permissions for current user, to store raw audio
# s3fs/blobfuse file system at $WEBFS with appropriate permissions for current user, to host HLS/encoded streaming
# folder at $TMP with read/write for current user

RAWFS=/mnt/rd/pbsorca/raw
WEBFS=/mnt/rd/pbsorca/web
SEGMENT_DURATION=30
# Duration for FLAC in minutes
FLAC_DURATION=2
LAG_SEGMENTS=6
LAG=$(( LAG_SEGMENTS*SEGMENT_DURATION ))
CHOP_M3U8_LINES=$(( LAG_SEGMENTS*(-2) ))
NODE_NAME=`hostname`
SAMPLE_RATE=44000
STREAM_RATE=22050
CHANNELS=2
# arecord -l to list devices
AUDIO_HW_ID=0

# Get current timestamp
timestamp=$(date +%s)

#### Set up local output directories
rm -rf $RAWFS/$NODE_NAME
rm -rf $WEBFS/$NODE_NAME
mkdir -p $RAWFS/$NODE_NAME
mkdir -p $WEBFS/$NODE_NAME

# Output timestamp for this (latest) stream
echo $timestamp > $RAWFS/$NODE_NAME/last-started.txt

echo "Node started at $timestamp"
echo "Node is named $NODE_NAME"

echo "Sampling from $AUDIO_HW_ID at $SAMPLE_RATE Hz..."
echo "Asking ffmpeg to write $FLAC_DURATION minutes $SAMPLE_RATE Hz lo-res flac files while streaming in both DASH and HLS..." 

## Streaming HLS segments and FLAC archive
while true
do
    echo Starting FFMPEG!
    
    ffmpeg -f pulse -ac 2 -ar $SAMPLE_RATE -thread_queue_size 1024 -i $AUDIO_HW_ID -ac $CHANNELS -ar $SAMPLE_RATE -sample_fmt s32 -acodec flac \
    -f segment -segment_time "00:$FLAC_DURATION:00.00" -strftime 1 "$RAWFS/$NODE_NAME/$NODE_NAME.%Y%m%d_%H%M%S.flac" \
    -f segment -segment_list "$WEBFS/$NODE_NAME/live.m3u8" -segment_wrap 10 -segment_list_flags +live -segment_time $SEGMENT_DURATION -segment_format mpegts -ar $STREAM_RATE -ac $CHANNELS -acodec aac "$WEBFS/$NODE_NAME/live%03d.ts" &

    sleep 8
    while [ $(pgrep ffmpeg) ] 
    do
        sleep 30
        azure-storage-azcopy copy --recursive "$WEBFS" "$WEBFS_SAS" --log-level warning
        azure-storage-azcopy copy --recursive "$RAWFS" "$RAWFS_SAS" --log-level warning
    done
done