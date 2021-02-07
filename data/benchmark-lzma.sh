#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'input.tar.lzma'
rm -f sizes-lzma.txt
hyperfine --export-json output-lzma.json --warmup 5 --prepare 'rm input.tar.lzma' --cleanup 'wc -c input.tar.lzma >> sizes-lzma.txt' --parameter-scan level 0 9 'lzma -{level} -k -z input.tar'
mv input.tar.lzma output.lzma
read