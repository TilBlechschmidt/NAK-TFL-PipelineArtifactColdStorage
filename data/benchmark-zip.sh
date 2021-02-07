#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.zip'
rm -f sizes-zip.txt
hyperfine --export-json output-zip.json --warmup 3 --prepare 'rm output.zip' --cleanup 'wc -c output.zip >> sizes-zip.txt' --parameter-scan level 1 9 'zip -{level} output.zip input.tar'
read