# metagenome_nf
Nextflow-based pipeline for metagenome analysis
https://docs.google.com/document/d/1wzGcBp868aPvKoOo0Jx8Z-lDEg5iVLzQVS-VXZIbthA/edit?tab=t.0#heading=h.4ikn9g84g3gq

```mermaid
%%{init: {'theme':'base'}}%%
flowchart TB
    subgraph " "
    v0["Reads"]
    v1["Kraken2 Database"]
    end
    v3([QCONTROL])
    subgraph " "
    v4["Quality Control Reports"]
    v6["Trimmed Reads"]
    v8["Kraken2 Classification"]
    v11["Spades Assembly"]
    v12["Spades Assembly Graph"]
    v13["Metagenomic Contigs"]
    v17["CheckM Plots"]
    v18["CheckM Quality Report"]
    v24["Final Report"]
    end
    v5([TRIM])
    v7([KRAKEN2])
    v9([BRACKEN])
    v10([METASPADES])
    v14([ALIGN])
    v15([METABAT])
    v16([CHECKM])
    v23([REPORT])
    v2(( ))
    v19(( ))
    v20(( ))
    v21(( ))
    v22(( ))
    v0 --> v3
    v0 --> v5
    v1 --> v2
    v3 --> v4
    v3 --> v20
    v5 --> v7
    v5 --> v6
    v5 --> v10
    v5 --> v14
    v5 --> v19
    v2 --> v7
    v7 --> v9
    v7 --> v8
    v7 --> v21
    v2 --> v9
    v9 --> v22
    v10 --> v13
    v10 --> v12
    v10 --> v14
    v10 --> v11
    v10 --> v15
    v14 --> v15
    v15 --> v16
    v16 --> v18
    v16 --> v17
    v19 --> v23
    v20 --> v23
    v21 --> v23
    v22 --> v23
    v23 --> v24
```

```mermaid
%%{init: {'theme':'base'}}%%
flowchart TB
    subgraph " "
    v0["Channel.fromFilePairs"]
    v1["Channel.fromPath"]
    v3["Channel.fromPath"]
    end
    v5([QCONTROL])
    subgraph " "
    v6[" "]
    v8[" "]
    v10[" "]
    v12[" "]
    v18[" "]
    v19[" "]
    v23[" "]
    v25[" "]
    v26[" "]
    v28[" "]
    v31[" "]
    v32[" "]
    v39[" "]
    end
    v7([TRIM])
    v9([MEGAHIT])
    v11([QUAST_CONTIGS])
    v14([ALIGN])
    v16([METABAT2])
    v17([CHECKM])
    v22([QUAST_BIN])
    v24([GTDBTK])
    v27([KRAKEN2])
    v29([BRACKEN])
    v30([KRONA])
    v38([REPORT])
    v2(( ))
    v4(( ))
    v13(( ))
    v15(( ))
    v20(( ))
    v33(( ))
    v0 --> v5
    v0 --> v7
    v1 --> v2
    v3 --> v4
    v5 --> v6
    v5 --> v33
    v7 --> v9
    v7 --> v8
    v7 --> v27
    v7 --> v13
    v7 --> v33
    v9 --> v10
    v9 --> v11
    v9 --> v13
    v9 --> v15
    v11 --> v12
    v11 --> v33
    v13 --> v14
    v14 --> v15
    v15 --> v16
    v16 --> v17
    v16 --> v24
    v16 --> v20
    v17 --> v19
    v17 --> v18
    v20 --> v22
    v22 --> v23
    v22 --> v33
    v4 --> v24
    v24 --> v26
    v24 --> v25
    v2 --> v27
    v27 --> v29
    v27 --> v28
    v27 --> v33
    v2 --> v29
    v29 --> v30
    v30 --> v32
    v30 --> v31
    v33 --> v38
    v38 --> v39
```
## Description

This pipeline is implemented in Nextflow and includes several stages for metagenomic data analysis:

- **QCONTROL (FastQC)**: Quality control of raw sequencing data using FastQC.
- **TRIM (fastp)**: Trimming of reads to remove adapters and low-quality sequences using fastp.
- **KRAKEN2 (Kraken2)**: Taxonomic classification of reads using Kraken2.
- **BRACKEN (Bracken)**: Estimation of species abundance based on Kraken2 outputs using Bracken.
- **MEGAHIT (MEGAHIT)**: Assembly of metagenomic sequences using MEGAHIT.
- **ALIGN (bwa)**: Alignment of reads to the assembled contigs using BWA MEM.
- **METABAT (MetaBAT2)**: Binning of assembled contigs into metagenomic bins using MetaBAT2.
- **QUAST_CONTIGS (QUAST)**: Quality assessment of assembled contigs using QUAST.
- **QUAST_BIN (QUAST)**: Quality assessment of each bin using QUAST.
- **CHECKM (CheckM)**: Quality assessment and visualization of metagenomic bins using CheckM.
- **GTDBTK (GTDBTk)**: Taxonomic annotation of bins GTDBTk.
- **REPORT (MultiQC)**: Compilation of a comprehensive report including QC metrics, taxonomic classification, and assembly results.

## Usage

### Quick Start

To quickly run the pipeline, use the following command:

```bash
nextflow run <your-username>/<your-repository> \
    -profile <docker/singularity> \
    --reads <path-to-reads-folder> \
    --kraken2_db <path-to-kraken2-database> \
    --outdir <path-to-results-folder>
```

### Requirements

- Nextflow (https://www.nextflow.io/docs/latest/install.html)
- Docker (https://docs.docker.com/engine/install/) or
- Singularity (https://github.com/sylabs/singularity/blob/main/INSTALL.md)

### Running the Pipeline

1. Install all the necessary dependencies such as Nextflow, Singularity.
3. Clone this repository: `git clone https://github.com/glebus-sasha/metagenome_nf.git`
4. Navigate to the pipeline directory: `cd octopus_nf`
5. Edit the `nextflow.config` file to set the required parameters, if necessary.
6. Run the pipeline, setting the required parameters, for example:

```bash
nextflow run main.nf
```
## Contributors

- Oxana Kolpakova ([@OxanaKolpakova](https://github.com/OxanaKolpakova))
- Glebus Aleksandr ([@glebus-sasha](https://github.com/glebus-sasha/))

## License

This project is licensed under the [MIT License](LICENSE).
