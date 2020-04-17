# Unified Streaming Live Origin Demo 
# DASH-IF Live Media Ingest Protocal - Interface 2 (DASH/HLS)

This demonstration shows a [Unified Streaming](http://www.unified-streaming.com/products/unified-origin) Origin setup with a Live publishing point (with Apache rewrite rules) and [FFmpeg](https://ffmpeg.org/) as an encoder to push HLS or DASH as a live ingest stream.

The demo consists of two Docker containers which are deployed using Docker Compose, alongside 4 optional ffmpeg scripts.

## Setup

1. Install [Docker](http://docker.io)
2. Install [Docker Compose](http://docs.docker.com/compose/install/)
3. Download this demo's [Compose file](https://github.com/unifiedstreaming/live-demo/blob/master/docker-compose.yaml)

## FFmpeg Scripts

The ffmpeg folder contains 4 scripts which can be used to overwrite the `ffmpeg/entrypoint.sh` containing the encoding configuration. 

Choices are:
* ffmpeg_dash_chunked.sh	
* ffmpeg_dash_singlefile.sh
* ffmpeg_hls_chunked.sh
* ffmpeg_hls_singlefile.sh

This can be done by running the following command in the directory of this demo: 
```bash
#!/bin/sh
cp ffmpeg/ffmpeg_dash_chunked.sh ffmpeg/entrypoint.sh
```

## Build FFmpeg

Once the `entrypoint.sh` has been overwritten the Docker image needs to be built locally.

This can be done by running the following command in the directory of this demo's Compose file:

```bash
#!/bin/sh
docker-compose build ffmpeg
```

Which will create a Docker image called livedemo_ffmpeg.

## Build Live-Origin

As this demostation utilises apache 'mod_rewrite' as an additional configuration the Docker image needs to be build locally.

```bash
#!/bin/sh
docker-compose build live-origin
```

Which will create a Docker image called livedemo_live-origin.

## Usage

You need a license key to use this software. To evaluate you can create an account at [Unified Streaming Registration](https://www.unified-streaming.com/licenses/access).

The license key is passed to containers using the *USP_LICENSE_KEY* environment variable.

Start the stack using *docker-compose*:

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up
```

You can also choose to run it in background (detached mode):

```bash
#!/bin/sh
export USP_LICENSE_KEY=<your_license_key>
docker-compose up -d
```

Now that the stack is running the live stream should be available in all streaming formats at the following URLs:

| Streaming Format | Playout URL |
|------------------|-------------|
| MPEG-DASH | http://localhost/test/test.isml/.mpd |
| HLS | http://localhost/test/test.isml/.m3u8 |
| Microsoft Smooth Streaming | http://localhost/test/test.isml/Manifest |
| Adobe HTTP Dynamic Streaming | http://localhost/test/test.isml/.f4m |


Watching the stream can be done using your player of choice, for example FFplay.

```bash
#!/bin/sh
ffplay http://localhost/test/test.isml/.m3u8
```

HLS Ingest will look something like:

![example](https://raw.githubusercontent.com/RufaelDev/live-demo/cmaf_ingest_dash_hls/ffmpeg/example_hls.png)

DASH Ingest will look something like:

![example2](https://raw.githubusercontent.com/RufaelDev/live-demo/cmaf_ingest_dash_hls/ffmpeg/example_dash.png)
