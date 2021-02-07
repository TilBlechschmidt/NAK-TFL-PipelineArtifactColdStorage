#!/bin/sh
cd /Users/themegatb/Developer/Studies/TFL/NAK-TFL-PipelineArtifactCompression/data/generated
touch 'output.tar.br'
rm -f sizes-brotli.txt
hyperfine --export-json output-brotli.json --warmup 3 --prepare 'rm output.tar.br' --cleanup 'wc -c output.tar.br >> sizes-brotli.txt' --parameter-scan level 0 9 'brotli -q {level} input.tar -o output.tar.br'
read