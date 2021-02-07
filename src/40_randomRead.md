# Random access

While general compression may improve the efficiency of data at rest, it complicates access to this data. With most common compression algorithms, all preceding bytes in a file up to a given index we want to access have to be decompressed. Especially in a continuous integration environment, this is problematic as artefacts are usually bundled per pipeline. Since pipelines usually generate HTML based reports with external resources like JavaScript or CSS, multiple accesses to a single archive are the norm. In this scenario, the ability to randomly access compressed data is beneficial. It allows for efficient storage on-disk while still permitting fast access.

In the following sections, we will be going over the fundamentals of how LZ77 based compression algorithms work, evaluate potential methods of enabling random access and analyse the drawbacks concerning compression ratio.

<!-- http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.156.1805&rep=rep1&type=pdf -->

## Fundamentals of LZ77

Before we begin with any evaluation of random access abilities, it is mandatory to talk about the possible ways random access can be implemented. For that, we have to look at the underlying concept of most compression algorithms. Out of all algorithms listed earlier, only two are not relying on the fundamental concept presented by Lempel and Ziv in 1977. For this reason, we will argue with the basic concepts of the LZ77 algorithm proposed in 1977. It is expected that the concepts hold for all other algorithms that are based on it.

The core principle of LZ77 is reference lookups. In its most basic form, the algorithm walks over a string and compares what it encounters with what it has encountered previously. To effectively do so, it keeps a buffer of the previously seen characters. With the original and most derivations, this lookup buffer size can be configured or even dynamically altered on the fly^[It should be noted that this buffer is almost always constrained in size. An unbounded buffer not only consumes large amounts of memory but also slows down the compression as the full buffer is searched through for each byte in the file.]. Regardless, it is only a setting that is relevant during compression. When decompressing a file compressed with LZ77, one only needs to resolve the references inserted earlier and instead insert the referenced bytes. [@lz77]

To gain an easier understanding of the concept, we will consider an example. Note that all examples have been taken from a compression algorithm writeup by Phillip Cutter. While it is not a scientific source in and of itself (for that one should reference the original papers for the relevant algorithms like source @lz77), it is a highly recommended read for a further introduction into the topic [@guide-to-compression].

> Original: Hello everyone! Hello world!
>
> Encoded: Hello everyone! <16,6>world!

In the example, the algorithm encountered the first character `H` and stored it in the lookup buffer. It did the same for every other character until it encountered the second `H`. At this point, it found the first one at the very beginning of the buffer^[The `e` also causes a lookup, but as it only ever matches a 1-character long string it will not be replaced since the reference is larger than the replaced sequence. An optimisation that strictly speaking is not part of the original algorithm, but LZSS, an extension by Storer et al. [@lzss]] and carries on comparing the following characters in the string with the following bytes in the buffer to find the longest matching substring. After the space, the substring match ends, and a reference is inserted. This reference can be interpreted as "go back 16 characters, copy six characters".

At a fundamental level, that is all there is to compression with LZ77. While there are more optimisations described in the paper and added on by newer algorithms like Zstd, the core stays the same.

## Block based compression {#sec:block-loss}

Now that we know the basic operational principles of LZ77 based compression, we may take a look at the possibility of random access. At first, we will consider a purely theoretical approach. Then, we will look at a more practical implementation and evaluate its performance with the same input data we used previously.

Since we know that LZ77 decompression relies solely on index-based lookups within the file, it should be viable to start decompression of a file at a random offset. Doing so requires frequent seeks for the first set of lookups since we have not yet encountered the referenced text. However, everything that comes after the reference buffer size used to compress the file will be decompressed as usual. This approach comes with one significant drawback: there is no reference of the uncompressed vs compressed byte offsets. Since the data we skipped by jumping ahead has an unknown number of references with unknown sizes, we can not know the byte offset. Without additional metadata, it is impossible to determine the decoded byte offset for a given input byte offset. In our scenario, this may be remedied by storing the byte offsets of each file we compress in an index stored either in-band at the beginning of the file, or out-of-band elsewhere.

Even though this method would work for a rudimentary implementation of LZ77 or LZSS, it is not that trivial when looking at modern derivates. Most APIs do not provide sufficiently low-level access to the decompressor to allow for this decompression method. While it may be considered a long-term goal to integrate this kind of random-access decompression into the public API, it is not feasible short-term.

For this reason, we will be looking at a more practical strategy which uses the same idea from before but in a way that is implementable with current APIs. Instead of decompressing a continuous stream of data starting at an offset, we will be using a block-based method. Instead of encoding the whole input as one long string, it will be cut into blocks of a fixed length. These blocks will then be compressed independently and their respective compressed and uncompressed offsets stored in an in-band metadata block. Compared to the previous approach, this is theoretically possible with any compression algorithm and does not require special low-level API features.

As previously mentioned, LZ77 keeps a fixed size, sliding window reference buffer (for simplicity, we will assume it is fixed). This means that at any given point in time during the compression, the algorithm will only ever insert references to data that is at most the reference buffers size away. Based on this knowledge, we can assert that compressing individual blocks instead of one consecutive file will only result in losses at the leading block edges where a previous block's content can not be referenced. For this reason, we expect a direct correlation between the block size and compression ratio with larger blocks, especially those larger than the sliding window size, having a higher ratio. Additionally, it is expected that the effectiveness is highly dependent on the block alignment and repetition of the input data. Future research may focus on analysing the input data to choose the best block size — potentially even variable block sizes — based on the input data. When compressing a set of files, it might even be possible to change the order in which they are compressed to put similar files into the same block. However, this kind of analysis is out-of-scope for this paper.

An additional benefit of a block-based compression is that the process of compressing the data may be parallelised. As each block is compressed independently, it is trivial to scale to as many threads as desired. Compared to regular algorithms, this might pose a significant advantage since many systems are equipped with multiple cores. While the CPU time required to compress a given file stays the same, the wall time required can be reduced by large factors — depending on the exact CPU core configuration.

For this paper, a reference implementation using the Zstd compression algorithm will be provided. This implementation uses the Rust bindings of the algorithm and is available in the accompanying source code repository^[Link omitted in this version of the document]. It takes a single file as input and outputs a file that contains concatenated independently compressed blocks. To keep it simple, the implementation does not add inline metadata or any framing for the blocks. However, as the block size is fixed and thus the number of blocks can be derived from the input data, we may statically determine the number of bytes this metadata would take if it were stored inline. For our exemplary input file, the number of blocks is calculated in @eq:block-count using a block size of 16MB. For simplicity, we will assume that each block requires two 32-bit unsigned integers for the uncompressed and compressed size in bytes^[For simplicity we assume that we compress a single file and that multiple files will be combined before compression using another container format.]. In all upcoming figures, the corresponding block metadata size is calculated and added.

\begin{equation}\label{eq:block-count}
  \begin{split}
    b_{count} & = \ceil*{i_{size} / b_{size}}\\
    b_{count} & = \ceil*{4.916.560.384 / 16.777.216}\\
    b_{count} & = 294
  \end{split}
\end{equation}

Before getting into the evaluation, we should look at a feature provided by the Zstd API. In addition to the rolling reference buffer based on the original LZ77 specification, it provides the possibility to specify a global dictionary which can be used for lookups. In theory, this should increase the compression ratio — especially in the block-based compression mode where we might otherwise lose some lookups at block borders. However, this mode comes with the drawback that the dictionary has to be known by both the compressor and decompressor. We will include this in the upcoming evaluation.

## Performance evaluation

We will now evaluate the compression ratio of different block sizes, with and without an external dictionary, and at different compression levels. Since we already evaluated the algorithm's general runtime performance, it will not be evaluated this time, and instead, we focus solely on the compression ratio. For evaluation, we consider three algorithm variations:

- **Regular:** Default CLI compression
- **Blocked:** Block based compression
- **Dictionary:** Block based compression with dedicated dictionary

It should be noted that the block metadata size is added to the compressed file size before calculation of the compression ratio. For the dictionary variant, the dictionary size is added as well since it is required for decompression. A line represents each variant in @fig:blocksizes^[Since the number of compression levels is a prime number, it is impossible to cleanly divide the number of labels on the X-Axis and thus increase the font-size.]. The X-Axis shows the compression ratio. The Y-Axis is split into multiple categories for each block size, where each category contains values for each available compression level.

![Block size comparison](src/images/lineplot-blocksize-compressionratio.pdf){#fig:blocksizes}

In general, the block-based compression is performing worse than the sequential compression, as expected. However, with increasing block sizes, the margin is getting smaller and smaller. At a size of 4MB, the block-based compression performs similarly at low compression levels. With increasing block size, it approaches the regular compression even at high compression levels. However, dictionary-based compression always lacks behind block-based compression. This may indicate that either the dictionary is not well suited for the data or the overhead of storing the dictionary inline. The latter can potentially be solved by generating a general dictionary which is embedded into the clients and used for all archives. However, it remains questionable whether the dictionary approach is well suited for the data at hand as it performs worse in all observed scenarios. It may be easier to rely on block-based compression without a dictionary as it simplifies the container and decompressor.

Overall, it appears that a block size of 8 MB at compression levels below ten and a block size of 16 MB at compression levels above that is well suited. It provides a reasonable trade-off between the access granularity, and by extent the amount of data that has to be decompressed even though we are not interested in it, and the compression loss.
