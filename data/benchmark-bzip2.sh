#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'input.tar.bz2'
rm -f sizes-bz2.txt
hyperfine --export-json output-bz2.json --warmup 3 --prepare 'rm input.tar.bz2' --cleanup 'wc -c input.tar.bz2 >> sizes-bz2.txt' --parameter-scan level 1 9 'bzip2 -{level} -k input.tar'
mv input.tar.bz2 output.bz2
read