#!/bin/bash

set -e

NDK=/Users/xmly/Library/Android/ndk-r19c
PLATFORM="$NDK/toolchains/llvm/prebuilt/darwin-x86_64/sysroot"
TOOLCHAIN=$NDK/toolchains/llvm/prebuilt/darwin-x86_64

archbit=$1

if [ $archbit -eq 32 ];then
echo "build for 32bit"
#32bit
ABI='armeabi-v7a'
CPU='arm'
API=19
ARCH='arm'
ANDROID='androideabi'
NATIVE_CPU='armv7-a'
OPTIMIZE_CFLAGS="-march=$NATIVE_CPU -mcpu=cortex-a8 -mfpu=vfpv3-d16 -mfloat-abi=softfp -mthumb"
CC="$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang"
CXX="$TOOLCHAIN/bin/armv7a-linux-androideabi$API-clang++"
else
#64bit
echo "build for 64bit"
ABI='arm64-v8a'
CPU='aarch64'
API=21
ARCH='arm64'
ANDROID='android'
NATIVE_CPU='armv8-a'
OPTIMIZE_CFLAGS="-march=$NATIVE_CPU"
CC="$TOOLCHAIN/bin/aarch64-linux-android$API-clang"
CXX="$TOOLCHAIN/bin/aarch64-linux-android$API-clang++"
fi

PREFIX="${PWD}/android/$ABI"
ADDITIONAL_CONFIGURE_FLAG="--cpu=$NATIVE_CPU"

LAMEDIR=$PREFIX
EXTRA_CFLAGS="-Os -fpic $OPTIMIZE_CFLAGS -I$LAMEDIR/include"
EXTRA_LDFLAGS="-lc -lm -ldl -llog -lgcc -lz -L$LAMEDIR/lib"

cd ffmpeg-4.3.1
make clean
rm -f compat/strtod.d
rm -f compat/strtod.o

# --enable-static \
# --disable-shared \

build_one(){
  ./configure --target-os=android \
--prefix=$PREFIX \
--enable-cross-compile \
--arch=$CPU \
--cc=$CC \
--cxx=$CXX \
--cross-prefix=$TOOLCHAIN/bin/$CPU-linux-$ANDROID- \
--sysroot=$PLATFORM \
--enable-neon \
--enable-hwaccels \
--pkg-config-flags="--static" \
--disable-doc \
--enable-asm \
--enable-small \
--disable-ffmpeg \
--disable-ffplay \
--disable-ffprobe \
--disable-debug \
--enable-gpl \
--disable-avdevice \
--disable-indevs \
--disable-outdevs \
--disable-avresample \
--extra-cflags="$EXTRA_CFLAGS" \
--extra-ldflags="$EXTRA_LDFLAGS" \
--enable-avformat \
--enable-avcodec \
--enable-avutil \
--disable-swscale \
--enable-swresample \
--disable-avfilter \
--disable-network \
--enable-bsfs \
--disable-postproc \
--disable-filters \
--disable-encoders \
--disable-decoders \
--enable-decoder=aac,aac_latm,flv,h264,mp3*,vp6f,flac,hevc,vp8,vp9,h263,h263i,h263p,mpeg4,mjpeg \
--enable-muxers \
--enable-parsers \
--enable-protocols \
--enable-jni \
--enable-mediacodec \
--enable-decoder=h264_mediacodec \
--enable-decoder=hevc_mediacodec \
--enable-decoder=mpeg4_mediacodec \
--enable-decoder=vp9_mediacodec \
--disable-demuxers \
--enable-demuxer=aac,hls,concat,data,flv,live_flv,mov,mp3,mpegps,mpegts,mpegvideo,flac,hevc,webm_dash_manifest,mpeg4,rtsp,mjpeg,avi \
--disable-parsers \
--enable-parser=aac \
--enable-parser=aac_latm \
--enable-parser=h264 \
--enable-parser=flac \
--enable-parser=hevc \
--enable-parser=mpeg4 \
--enable-parser=mpeg4video \
--enable-parser=mpegvideo \
--enable-bsfs \
--disable-bsf=chomp \
--disable-bsf=dca_core \
--disable-bsf=dump_extradata \
--disable-bsf=hevc_mp4toannexb \
--disable-bsf=imx_dump_header \
--disable-bsf=mjpeg2jpeg \
--disable-bsf=mjpega_dump_header \
--disable-bsf=mov2textsub \
--disable-bsf=mp3_header_decompress \
--disable-bsf=mpeg4_unpack_bframes \
--disable-bsf=noise \
--disable-bsf=remove_extradata \
--disable-bsf=text2movsub \
--disable-bsf=vp9_superframe \
--enable-protocols \
--enable-protocol=async \
--disable-protocol=bluray \
--enable-protocol=concat \
--enable-protocol=crypto \
--disable-protocol=ffrtmpcrypt \
--enable-protocol=ffrtmphttp \
--disable-protocol=gopher \
--disable-protocol=icecast \
--disable-protocol=librtmp* \
--disable-protocol=libssh \
--disable-protocol=md5 \
--disable-protocol=mmsh \
--disable-protocol=mmst \
--disable-protocol=rtmp* \
--enable-protocol=rtmp \
--enable-protocol=rtmpt \
--enable-protocol=rtp \
--enable-protocol=sctp \
--enable-protocol=srtp \
--disable-protocol=subfile \
--disable-protocol=unix \
--disable-devices \
--disable-filters \
$ADDITIONAL_CONFIGURE_FLAG
make
make install

#$TOOLCHAIN/bin/$CPU-linux-$ANDROID-ld -rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib \
#-L$PREFIX/lib -soname libffmpeg.so \
#-shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o $PREFIX/libffmpeg.so \
#$PREFIX/lib/libavformat.a \
#$PREFIX/lib/libavcodec.a \
#$PREFIX/lib/libavutil.a \
#$PREFIX/lib/libswscale.a \
#$PREFIX/lib/libswresample.a \
#-lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker $TOOLCHAIN/lib/gcc/$CPU-linux-$ANDROID/4.9.x/libgcc.a
}

build_one
