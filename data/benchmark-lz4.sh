#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.lz4'
rm -f sizes-lz4.txt
hyperfine --export-json output-lz4.json --warmup 3 --prepare 'rm output.lz4' --cleanup 'wc -c output.lz4 >> sizes-lz4.txt' --parameter-scan level 1 12 'lz4 -{level} input.tar output.lz4'
read