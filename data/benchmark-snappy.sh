#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'input.tar.sz'
rm -f sizes-snappy.txt
hyperfine --export-json output-snappy.json --warmup 10 --prepare 'rm input.tar.sz' --cleanup 'wc -c input.tar.sz >> sizes-snappy.txt' 'szip --keep input.tar'
mv input.tar.sz output.sz
read