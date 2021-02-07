---
    header-title: Transfer paper 6
    title: Effective cold-storage of CI pipeline artifacts

    author: Til Blechschmidt
    Zenturie: A17a
    Studiengang: Angewandte Informatik
    Matrikelnummer: 8240

    # This can be replaced with any valid bibliography file (.yaml, .json, .bib)
    bibliography: src/bibliography.json

    lang: en

    figPrefix:
      - "figure"
      - "figures"

    secPrefix:
      - "section"
      - "sections"

    linestretch: 1.25
---

\newcommand\todo[1]{\textcolor{red}{TODO #1}}

# Introduction

Over the years, the prices for computer storage have decreased [@hdd-prices]. At the same time, consumption has grown significantly [@ssd-sales] [@hdd-shipments-1] [@hdd-shipments-2]. In the meantime, software development has seen a trend towards automated and continuous testing [@devops] [@ci-usage] [@devops-importance].

By looking at an example from PPI AG, it becomes clear that pipelines produce vast amounts of data. A two-hour test suite outputs approximately 5GB of logs and debugging information. The team of roughly 40 employees using these runs about 2.200 pipelines a month which amounts to just under 360GB a day. However, this data is not only produced for static analysis. It should be accessible for extended periods so that potential issues and test failures can be debugged. Given the example, a 4TB drive lasts for less than two weeks (ignoring redundancy and storage speeds requirements).

This presents a significant scalability challenge as multiple teams might require potentially hundreds of terabytes a month, depending on the company's size. For this reason, optimising the storage usage and thus making the best use of the available storage is paramount to achieve efficient scalability. The arguably simplest method to increase storage density is by the use of compression algorithms. Based on that, we can formulate the primary research question of this paper:

> Which compression algorithms are suited for archival of pipeline artefacts?

Furthermore, we shall consider the nature of the data at hand. It may be considered semi-volatile as it is written once and accessed a few times over a period of less than a week^[Further research regarding the actual storage period is being conducted in parallel.]. For this reason, the data may be considered read-only until it is eventually deleted. The data access may not be considered sequential as the developer is expected to query HTML reports and log files depending on the type of issue encountered. It is thus randomly accessed. Given that the data is compressed at rest, we may formulate our secondary research question:

> How to ensure random read-only access to compressed data?

To answer these questions, the paper will be split into two parts. In @sec:compression, we will be evaluating the CPU resource usage and compression ratio of different compression algorithms based on a data set collected from the previously mentioned development team. Later on, we will be looking at possible methods to allow random access to compressed data.

<!--
- Word definition
  - Compression ratio
  - Algorithm runtime (CPU time)
  - Compression level (CLI flag)
-->

\pagebreak
