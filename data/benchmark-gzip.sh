#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'input.tar.gz'
rm -f sizes-gzip.txt
hyperfine --export-json output-gzip.json --warmup 3 --prepare 'rm input.tar.gz' --cleanup 'wc -c input.tar.gz >> sizes-gzip.txt' --parameter-scan level 1 9 'gzip -{level} --keep input.tar'
mv input.tar.gz output.gz
read