#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.tpxz'
rm -f sizes-pixz.txt
hyperfine --export-json output-pixz.json --warmup 3 --prepare 'rm output.tpxz' --cleanup 'wc -c output.tpxz >> sizes-pixz.txt' --parameter-scan level 0 6 'pixz -p 1 -{level} input.tar output.tpxz'
read