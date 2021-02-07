## Evaluation

The algorithms have been evaluated on a 16" MacBook Pro^[The exact identifier is MacBookPro16,1] with 16GB of RAM and an Intel Core i9-9880H running macOS 11.2 (20D5029f). The results of a synthetic benchmark on the machine along with additional hardware specifications can be found under the following URL: [https://browser.geekbench.com/v5/cpu/5846065](https://browser.geekbench.com/v5/cpu/5846065). Each algorithm was restricted to a single core using appropriate command-line flags where relevant. The exact commands and data evaluation tools can be found in the Appendix and accompanying GitHub repository^[To maintain author anonymity, the link has been excluded in this version of the document] respectively.

Another relevant variable is the input data. Since this paper explicitly focuses on the topic of CI pipelines, an example taken from such a pipeline will be used^[The exact data set is not provided to allow unrestricted publication of this paper. If you require access, please contact the author.]. The artefact directory comes from a project at PPI AG and is approximately 226 Megabytes in size^[Note that this is the raw data size not taking block alignment and losses due to the storage medium into account]. It contains 6721 files of varying sizes with the file type frequencies listed in [@tbl:file-types].

| Count | Mime type                                                                                                                                       |
|------:|:------------------------------------------------------------------------------------------------------------------------------------------------|
|  3795 | text/plain                                                                                                                                      |
|  1715 | application/json                                                                                                                                |
|   336 | inode/x-empty^[Empty inodes are used for lock files and for files that act as status flags (in addition to ones that are empty by coincidence)] |
|   355 | text/xml                                                                                                                                        |
|   290 | application/octet-stream                                                                                                                        |
|   215 | text/html                                                                                                                                       |
|     6 | application/csv                                                                                                                                 |
|     3 | application/vnd.ms-fontobject                                                                                                                   |
|     3 | font/sfnt                                                                                                                                       |
|     3 | image/svg+xml                                                                                                                                   |

Table: Mime types of files in input data. {#tbl:file-types}

Since not every algorithm evaluated can combine multiple files into a single compressed archive, all files have been archived using the TAR format before compression. The archive is 232 Megabytes in size due to the added file metadata^[Each file in a TAR archive has an associated 512-byte header].

![Algorithm efficiency](src/images/lineplot-runtime-compressionratio.pdf){#fig:speed}

\FloatBarrier

Each algorithm is plotted in [@fig:speed] by its configuration levels with the runtime plotted on the X-axis (lower is better) and the compression ratio of the resultant archive on the Y-axis (higher is better). Since an increase of compression level uniformly caused a rise in runtime, the data points are not labelled further^[Lowest algorithm runtime equals lowest compression level and the data points are connected in ascending order]. Each data point represents the median of all runs with minimum and maximum measurements expressed through error bars. All algorithms behaved deterministically, and thus no vertical error bars are present.

**Snappy:** Since this algorithm did not have configurable compression levels, it is only represented by a single data point in the bottom left of the graph. As claimed by the algorithm's description, it performs exceptionally fast at the expense of compression ratio with the lowest of all at approximately 6x compression. While this is not useful for archival of pipelines, it is favourable for transport compression, and thus the algorithm achieves its intended goal. However, it should be noted that other algorithms like LZ4, Brotli, or Zstd achieve significantly higher compression ratios at approximately the same computational expense.

**LZO:** At its lowest level, this algorithm operates comparably to Snappy^[It should be noted that decompression speeds are not evaluated and it is possible that their respective decompression speeds diverge]. At higher levels, it becomes comparable to Deflate, albeit using more CPU resources and not quite reaching the maximum compression ratio of Deflate.

**Deflate:** Both gzip and zip use the Deflate algorithm (see [@sec:deflate]) and thus, as expected, they perform roughly equal with gzip being marginally faster. While these two exhibit relatively low compression ratios, they perform reasonably fast even at high compression levels. Although the gain beyond compression level 6 is negligible.

**LZ4:** Even though LZ4 does not use an entropy coding stage^[This could potentially be the reason why it performs better on this particular input — further research is required], it outperforms Deflate slightly in terms of runtime and compression ratio at all levels.

**Brotli:** Of all algorithms, Brotli has the best scaling in relation to the configured compression level. The lower levels provide significant gains in compression ratio at marginal runtime increase while the upper levels asymptotically approach a maximum compression level at the increasing cost of computing resources.

**LZMA:** LZMA and pixz^[pixz uses LZMA under the hood] start with higher computational complexity than Zstd or Brotli but at the same time provide a higher compression ratio at low levels. At levels higher than 4, the increase in compression ratio becomes marginal in relation to the runtime. However, LZMA ends off with a sharp rise in compression ratio at the four highest levels. Ultimately, it surpasses even Brotli and provides the highest compression ratio of all tested algorithms. In comparison, pixz always lacks behind LZMA in terms of compression ratio^[This is likely due to the added container metadata required and the block-based compression. See [@sec:block-loss] for more detail.] and does not exhibit the same sharp rise at the extreme compression levels.

**Zstandard:** At low levels, Zstd compresses faster and with a higher compression ratio than Brotli. However, at levels higher than seven it falls behind and uses significantly more computing resources. Notably, it exhibits a drop in compression ratio at level 14 for unknown reasons.

All algorithms we covered so far are based on a dictionary compression stage which evolved from the work of Lempel and Ziv [@lz77] and some combined it with additional entropy matching (mostly Huffman or FSE). However, one algorithm is left, and that is BZip2. In contrast to the others, it does not use the dictionary method and instead relies on a combination of Run-length encoding, and Burrow-Wheeler transforms along with Huffman encoding [@bzip2].

**BZip2:** The different approach to compression that this algorithm takes is clearly reflected in the graph. It takes a considerably larger amount of time than all other algorithms (only pixz at the highest level is comparable to the lowest level of BZip). At the time of release (1996), it achieved significantly higher compression ratios than other LZ77 based algorithms from that time (namely LZO, LZ4, and Deflate). However, shortly after in 1998, LZMA was published, which achieved significantly higher ratios at lower ratios (as seen in [@fig:speed]) [@lzma-release].
