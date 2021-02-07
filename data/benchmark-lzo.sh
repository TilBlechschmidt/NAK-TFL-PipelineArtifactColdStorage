#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.lzo'
rm -f sizes-lzo.txt
hyperfine --export-json output-lzo.json --warmup 3 --prepare 'rm output.lzo' --cleanup 'wc -c output.lzo >> sizes-lzo.txt' --parameter-scan level 1 9 'lzop -{level} -o output.lzo input.tar'
read