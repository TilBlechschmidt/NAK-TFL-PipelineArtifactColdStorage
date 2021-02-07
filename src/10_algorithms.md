# Compression performance {#sec:compression}

To answer the first research question, we will be outlining a number of different compression algorithms and their relationship with others. Furthermore, we will be running compression performance tests for every algorithm with a context-specific input data set.

## Algorithms

Before we talk about specific algorithms, it is crucial to define some terminology clearly. When talking about a compression tool in general, one may refer to a multitude of terms. Each of these terms represents a layer in the compression stack. At the very bottom is the fundamental compression method or algorithm. While algorithms themselves may be comprised of multiple stages (e.g. dictionary compression and entropy-based encoding), they usually output a single continuous binary blob. On the next layer up, this binary blob may be stored in a container format. Such a container format may define framing and allow additional metadata to be embedded in an archive file. However, it should be noted that compression algorithms do not inherently require a container format. It is very well possible to store the raw compressed data in a file, and some of the tools we will look at are doing precisely this. At the top of the stack is the CLI tool which provides a user-interface to either the container format or algorithm.

We will now be outlining a number of algorithms. Each algorithm will be used through its respective CLI tool, and it may or may not use a container format (which will be noted).

**Brotli:** The first algorithm is called Brotli. It has been published as RFC 7392 by Jyrki Alakuijala, Zoltán Szabadka and relies on a combination of LZ77 based dictionary compression and Huffman coding [@rfc7932] [@huffman]. We will be using version 1.0.9 of the CLI tool published by Google Inc. on GitHub. The RFC defines a container format, and thus the resulting data is framed.

**Bzip2:** In contrast to Brotli, Bzip2 is not based on the fundamental principles of LZ77. Instead, it relies on a Burrows-Wheeler transform and a secondary Huffman coding stage. Unfortunately, few specification documents are available, and most information available is based on a reverse-engineered specification by Joe Tsai [@bzip2]. However, for evaluation, we will be using the official CLI with version 1.0.6, which also outputs a container format.

**Gzip:** Next up is Gzip which relies on the DEFLATE algorithm defined in RFC 1951 [@rfc1951]. This algorithm relies on LZSS, which itself is a derivate of LZ77 [@lzss], and uses an additional Huffman encoding. Gzip defines a specific container format in RFC 1952, which is used with the CLI tool [@rfc1952]. We are using Apple gzip 321.40.3.

**LZ4:** This algorithm, called LZ4, is a close derivate of LZ77 with no additional entropy stage. A streaming container format is available and used by the CLI. The version used for evaluation is 1.9.3 by Yann Collet.

**LZMA:** Another algorithm that closely follows LZ77 is LZMA [@lzma-release]. It should be noted that a different version called LZMA2 is available. However, the underlying compression is the same. The extension adds support for uncompressed sub-chunks. This is used by the xz container format, but for our evaluations, we will use the algorithm directly through the liblzma 5.2.5 library.

**LZOP:** Yet another derivate of LZ77 is Lempel–Ziv–Oberhumer. It provides both a CLI and container format, and we are using version 1.04 for testing.

**PIXZ:** A closely related algorithm to LZMA. It is a high-level wrapper of the XZ container format and by extent LZMA2. It allows multi-threaded compression and decompression as well as random access^[Using the same method, we will analyse in more detail further down the line.]. According to the specification, it is the same container format as XZ but stores additional metadata in trailing blocks which are ignored by the normal XZ decompressor. We are using version 1.0.7 of the CLI tool.

**Snappy:** Derived from the LZ77 dictionary compression, this algorithm is optimised for speed over compression ratio. According to public documentation, it has been developed with the intent of compressing web traffic in-flight. We are using version 1.0.0 of the szip CLI tool.

**ZIP:** This ubiquitous CLI tool uses the same DEFLATE algorithm as Gzip but defines a different framing format. We are using version 3.0.

**Zstd:** Defined by RFC 8478, this algorithm is based on LZ77 like many others [@rfc8478]. However, it extends it by a Huffman coding for literals and finite-state entropy stage for sequences [@zstd].

<!-- - Differentiate
  - CLI Tool
  - Container format
  - Underlying algorithm
  - Fundamental compression methods / stages
  - Reference Hitchhiker's guide to compression
  
- Brotli [1.0.9]
  - LZ77 + Huffmann [@huffman]
  - https://tools.ietf.org/html/rfc7932
- Bzip2 [1.0.6]
  - Burrows–Wheeler + Huffmann
- Gzip (CLI/Container, DEFLATE) [Apple gzip 321.40.3]
  - https://tools.ietf.org/html/rfc1952 (container format)
  - https://tools.ietf.org/html/rfc1951 (deflate algorithm)
  - LZSS (which is based on LZ77) + Huffmann
- LZ4 [LZ4 command line interface 64-bits v1.9.3, by Yann Collet]
  - https://lz4.github.io/lz4/
  - Streaming container format available
  - Derived from LZ77 (no Huffmann)
- LZMA [liblzma 5.2.5]
  - Derived from LZ77
  - LZMA2 is a high-level abstraction which supports uncompressed chunks
  - Used by XZ container
- LZOP (CLI/Container, LZO) [v1.04]
  - Lempel–Ziv–Oberhumer (derived from LZ work)
- PIXZ [1.0.7]
  - XZ / LZMA under the hood
  - Multi-threaded block based wrapper
  - Allows random access by abusing frame format specifications
- Snappy [szip 1.0.0]
  - LZ77 derived dictionary compression
  - Designed for speed (transport compression) over compression ratio
- Zip (CLI/Container, DEFLATE) [Zip 3.0]
  - Deflate (see Gzip)
- Zstd [v1.4.8]
  - https://tools.ietf.org/html/rfc8478
  - LZ77 dictionary matching
  - Huffmann + Finite state entropy stage (literals vs. sequences)
    - https://github.com/Cyan4973/FiniteStateEntropy
    - [@zstd]
-->
