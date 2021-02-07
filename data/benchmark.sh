#!/bin/sh
mkdir -p generated/
cp small.tar generated/input.tar

open -a iTerm benchmark-brotli.sh
open -a iTerm benchmark-bzip2.sh
open -a iTerm benchmark-gzip.sh
open -a iTerm benchmark-lz4.sh
open -a iTerm benchmark-lzma.sh
open -a iTerm benchmark-lzo.sh
open -a iTerm benchmark-pixz.sh
open -a iTerm benchmark-snappy.sh
open -a iTerm benchmark-zip.sh
open -a iTerm benchmark-zstd.sh
