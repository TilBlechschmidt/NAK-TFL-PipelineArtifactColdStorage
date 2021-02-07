# Conclusion

In this research paper, we evaluated the performance of a number of compression algorithms. The results showed that at low compression levels, Zstd is favourable. However, at higher compression levels, Brotli is more efficient and achieves a higher overall compression ratio. For the highest compression rate of all observed algorithms, LZMA is optimal. It should be noted that these results are heavily dependent on the input data used. Caution should be applied when using them for anything other than CI test pipeline artefacts^[Even then the contents may differ sufficiently to change the balance of different algorithms. Re-evaluation using the tools provided in the accompanying source code repository is recommended.].

In addition to the performance analysis, we performed a theoretical evaluation of possible methods to enable random access to compressed data. One of these theories has been turned into a proof-of-concept and tested against existing compression algorithms. Surprisingly, only small losses in terms of compression ratio have been encountered, suggesting that efficient random access and thus compression of data at rest is viable.

During the evaluation, a number of variables have not been controlled for various reasons. First, the CPU core frequency was not pinned, and it is possible that it fluctuated. Additionally, the thermal system has caused thermal throttling. While we attempted to minimise the effects by doing warmup runs for each algorithm until the system reached a thermal steady-state, it is impossible to rule out any interference. In the future, it is recommended to run the tests on a system which does not throttle under heavy load^[Unfortunately, no such hardware was available for this paper.]. Furthermore, it might be possible that some algorithms have compiled with CPU specific optimisations as each tool was compiled independently by the corresponding distributors. Finally, it should be noted that all compression tests have operated on-disk as opposed to in-memory. While the SSD used has a bandwidth of approximately 3 GB/s each way, which presumably exceeds the compression algorithm speed, it is an uncontrolled variable. Ideally, the data should be loaded into memory first for future tests.

Future research may focus on the effect that different inputs have on the compression algorithms as this has not been covered in this paper. Additionally, we encountered a potentially interesting phenomenon where algorithms with an entropy-based coding stage outperformed those without. Analysing this further may provide more detailed, valuable insights. Another factor which we did not evaluate is the decompression speed of different algorithms. While it is not of significant relevance for this particular scenario, it might serve as a tiebreaker for similarly performing algorithms.

\pagebreak

<!--
https://github.com/google/brotli/blob/master/docs/brotli-comparison-study-2015-09-22.pdf              
-->
