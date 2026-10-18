# WheatPanRef: scripts for iterative sequence discovery and integration

This repository contains research scripts used in the development of **WheatPanRef**, a linear pan-reference framework for hexaploid bread wheat (*Triticum aestivum*). The scripts in this release illustrate two successive accession-specific stages, **CM42** and **ZM16**, of the sequence-discovery and sequence-comparison workflow.

> **Scope of this code release.** The scripts provided here are a *partial, historical workflow snapshot*, not a complete or independently runnable implementation of WheatPanRef v1.3. They require external input assemblies, intermediate files, third-party tools, and local configuration. Other components of the study—including assembly reconciliation, all 37 accession-integration steps, final NCP pseudomolecule construction, genome annotation integration, coordinate translation, and downstream analyses—are not contained in this snapshot. See [Limitations and reproducibility](#limitations-and-reproducibility).

## Overview

The workflow was designed to identify regions insufficiently represented by an existing wheat reference and to evaluate candidate non-reference intervals before integration. At a high level, it includes:

1. **Read preparation and alignment.** Prepare short-read data (including simulated reads where applicable), align them to the candidate assembly, and process the resulting BAM files.
2. **Depth-based candidate detection.** Count alignments in overlapping genomic windows, normalize counts, and identify putatively underrepresented intervals.
3. **Multi-scale interval refinement.** Refine candidate intervals using multiple window sizes and select intervals supported across scales.
4. **Sequence comparison.** Align candidate intervals to the Chinese Spring backbone using MUMmer/nucmer, filter alignments, and calculate an alignment-based similarity/coverage score.
5. **Sequential comparison.** In the ZM16 example, additional scripts permit comparison with sequences selected from the preceding CM42 stage.
6. **Sequence collection.** Extract candidate sequences and append selected FASTA records to a reference FASTA for further processing.

The decision threshold and analysis paths are embedded in the original scripts; in particular, depth-normalized windows are labelled as candidate deletions at **≤ 0.5** in `00.call_CNV/01.call_CNV.sh`, and the sequence-selection scripts use a similarity-score cutoff of **≤ 30** in the provided implementation. These are code-level observations and should be checked against the parameters ultimately reported in the manuscript.

## Repository structure

```text
.
├── README.md
├── 01.CM42/
│   ├── 03.fastp.sh                 # Read preprocessing
│   ├── bwa.sh                      # Short-read alignment
│   ├── FilterBam.sh                # Alignment filtering
│   ├── MergeAndSplitBam.sh         # Chromosome-level BAM processing
│   ├── 00.call_CNV/               # Windowed read-depth and interval selection
│   │   ├── call_DP.sh
│   │   ├── 01.call_CNV.sh
│   │   ├── script_un1k.sh
│   │   ├── sel_win.py
│   │   ├── sel_true_block.py
│   │   ├── sel_win_100k.py
│   │   └── sel_true_100k_block.py
│   └── 01.col/                    # Candidate extraction and sequence comparison
│       ├── 00.mk_100k_colfile.sh
│       ├── 01.col_CS.sh
│       ├── 02.filter_coords.sh
│       ├── 02.filter_100k_coords.sh
│       ├── 03.eva_col_CS.sh
│       ├── 03.eva_100k_col_CS.sh
│       └── 07.get_merge_fa.sh
└── 02.ZM16/
    ├── 02.fangzhen.sh             # Example simulated-read generation
    ├── 03.fastp.sh
    ├── bwa.sh
    ├── FilterBam.sh
    ├── MergeAndSplitBam.sh
    ├── 00.call_CNV/               # As above, including sample-specific variants
    └── 01.col/                    # Sequence comparison and the preceding-stage link
        ├── 00.link_fa.sh
        ├── 01.col_CS.sh
        ├── 01.col_2block.sh
        ├── 03.eva_col_CS.sh
        ├── 03.eva_2block.sh
        └── 07.get_merge_fa.sh
```

This is a **functional overview**, not a complete file listing. The original directory names and filenames have been retained to make it easier to trace the research workflow. Ancillary submission scripts, plots, and alternative-window scripts may also be present.

## Software requirements

The scripts were written for a Linux HPC environment with a SLURM scheduler. Software used or imported in the supplied files includes:

- Bash, GNU coreutils, AWK/gawk, `bc` and common Unix utilities
- `fastp`, `bwa`, `samtools`, `bamtools`, `bedtools`
- MUMmer 4 (`nucmer`, `delta-filter`, `show-coords`)
- Python 3, `pandas`, `numpy`; `scipy` is imported by an ancillary historical script
- R, `ggplot2` and `gridExtra` (visualization scripts)
- An external read simulator, `GenerateReads_WG_PE`, and helper script `fasta2fastq.py` (both **not included**)
- SLURM (`sbatch`, `srun`) for the provided cluster-submission wrappers

**Exact software versions and a tested installation environment have not been reconstructed from this archive.** In particular, these historical scripts use `samtools rmdup` and a MUMmer 4 beta executable path; replacement with current tools requires validation.

## Required input files

At minimum, a reproducible run requires the relevant Chinese Spring reference assembly, the accession assemblies (CM42 and ZM16), and their FASTA indices; the read input or the missing read simulator and helper; BED intervals for all analysis window sizes; chromosome and BAM lists and filtering rules; and storage for intermediate FASTQ, BAM, coverage and alignment files.

Typical input/output conventions visible in the scripts are:

| Input/output | Example or convention | Purpose |
| --- | --- | --- |
| Accession assembly | `CM42.fa`, `ZM16.fa` | Candidate-sequence extraction and mapping |
| Existing reference | Chinese Spring FASTA, chromosome FASTAs | Comparison and reference extension |
| Sliding-window BEDs | `chr1A.1.win_100k_step_20k.bed` | Read-depth counting; two chromosome partitions (`.1` and `.2`) are assumed in parts of the pipeline |
| Depth profiles | `chr*.DP` and `chr*.norm` | Detection of low-coverage candidate intervals |
| Refined candidate intervals | `com_true_del_block.txt`, `com_true_100k_del_block.txt` | Sequence extraction |
| Alignment coordinates | `03.coords/01.toCS/*.coord.txt` | Reference-versus-candidate comparison |
| Similarity summaries | `simi_CS.txt`, `simi_CS_100k.txt` | Candidate filtering |
| Integrated FASTA | `genome_1.fa` | Historical output of the candidate FASTA collection step |

The filenames above describe existing conventions, not an accompanying example dataset. **This archive does not include the required sequence data, BED generation workflow or sample configuration files.**

## Typical execution order

The commands below are an **illustrative outline**, not a validated end-to-end run command. Execute steps from the corresponding accession directory and its `00.call_CNV/` or `01.col/` subdirectory, after configuring all paths and generating the required inputs.

1. Generate or supply paired-end reads. In the ZM16 example, `02.fangzhen.sh` refers to a FASTA produced after the CM42 stage; the external simulation programs must be supplied separately.
2. Preprocess paired FASTQ files using `03.fastp.sh`, then map the reads using `bwa.sh`.
3. Process BAM files with `FilterBam.sh` and `MergeAndSplitBam.sh`, after providing the site-specific filtering configuration and chromosome lists.
4. Within `00.call_CNV/`, use `call_DP.sh` to estimate read counts in predefined BED windows. Then run `01.call_CNV.sh` (which invokes `script_un1k.sh`) to generate normalized coverage profiles and candidate intervals.
5. Refine intervals using `sel_win.py` followed by `sel_true_block.py`. When the 100-kb-specific branch is used, apply `sel_win_100k.py` and `sel_true_100k_block.py` after the requisite coverage profiles exist.
6. Within `01.col/`, extract the selected candidate FASTA intervals using an applicable `00.mk*_colfile.sh`, align them to Chinese Spring using `01.col_CS.sh`, filter alignment coordinates with the corresponding `02.filter*_coords.sh`, and estimate similarity using `03.eva*_col_CS.sh`.
7. For successive accessions, examine the optional preceding-stage comparison scripts (`00.link_fa.sh`, `01.col_2block.sh`, `03.eva_2block.sh` in ZM16). The historical FASTA-collection step is `07.get_merge_fa.sh`.

The provided `.tosub*.sh` files are HPC-specific submission wrappers. They are not required to understand the algorithms, and they must be adapted to the local scheduler before use. **Do not execute the archived `rm.sh` housekeeping scripts as part of the pipeline; they delete intermediate input data.**

## Parameters visible in the scripts

| Parameter | Implementation in the uploaded scripts |
| --- | --- |
| Read trimming | `fastp` with read length ≥ 36 bp and the original quality-window settings |
| Read alignment | `bwa mem -t 16` |
| Window sizes | 1 Mb, 500 kb, 200 kb, 100 kb, 50 kb, 40 kb, 30 kb, 20 kb and 10 kb |
| Step sizes | Respectively 200 kb, 100 kb, 40 kb, 20 kb, 10 kb, 8 kb, 6 kb, 4 kb and 2 kb |
| Candidate depth cutoff | Normalized depth ≤ 0.5 |
| Adjacent interval merging | `bedtools merge -d 500` |
| Nucmer alignment | `nucmer -c 100 -l 50 --mum` |
| Delta filtering | `delta-filter -o 90 -1` |
| Candidate selection | Similarity-score cutoff ≤ 30 in the FASTA collection step |

Parameter names and outputs should be reconciled with the final Methods section before publication. The scripts do not, by themselves, establish how many reads correspond to the simulated depth reported in the manuscript.

## Limitations and reproducibility

The following issues should be addressed before presenting this repository as runnable, peer-review-ready code:

- Most scripts contain **absolute paths to a former HPC directory and executable installations**. Replace them with command-line options or a single documented configuration file.
- Several required scripts/files are **missing**, notably `GenerateReads_WG_PE`, `fasta2fastq.py`, `wait_niu.sh`, `filter_list.txt`, `ID_list.txt`, `FILTERED_BAMS.txt`, `chr_list.txt`, and window BED inputs.
- Some cluster submission scripts use old SLURM partition settings and job dependencies. Their ordering and resource settings have **not** been validated on a new system.
- The ZM16 `01.col/04.split_col_file.sh` tests the **third column** although its upstream `03.eva_col_CS.sh` currently writes **two columns**; verify and correct this mismatch before use.
- CM42 `01.col/00.mk_colfile.sh` currently reads `a.tmp`, a local temporary filename, rather than a documented candidate interval output.
- CM42 `00.call_CNV/03.plot_block.sh` invokes interval-selection Python scripts rather than a plot command, despite its filename.
- The historical script `07.get_merge_fa.sh` appends selected intervals to a Chinese Spring FASTA; it does not document the final WheatPanRef v1.3 chromosome-scale integration, redundancy resolution, NCP joining and quality-control steps.
- The uploaded archive was **statically inspected**, but the workflow has **not** been executed or validated end to end with the original inputs.

## Data availability

The input assemblies, sequencing datasets and released WheatPanRef reference are not embedded in this code snapshot. Dataset accessions, assembly releases and the final reference download should be linked from the accompanying manuscript and its Data availability statement.

Project resource: [WheatPanRef](https://wheat.cau.edu.cn/WheatPanRef/).

## Citation

If you use these scripts, please cite the associated WheatPanRef paper **once its bibliographic details are available**. The manuscript citation and any version-specific repository DOI should be added to this section when available.

## License

**A license has not yet been selected for this code snapshot.** Before a public release, the authors should choose and add an appropriate `LICENSE` file, confirming that any third-party material included can be redistributed under that license. Do not assume that the absence of a license permits unrestricted reuse.

## Contact

For questions regarding the study or code, please use the corresponding-author contact information provided in the associated manuscript or the eventual GitHub repository settings.
