#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.zst'
rm -f sizes-zstd.txt
hyperfine --export-json output-zstd.json --warmup 3 --prepare 'rm output.zst' --cleanup 'wc -c output.zst >> sizes-zstd.txt' --parameter-scan level 1 18 'zstd -T1 -{level} input.tar -o output.zst'
read