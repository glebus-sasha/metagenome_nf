# metagenome_nf
Nextflow-based pipeline for metagenome analysis
[Instruction](https://docs.google.com/document/d/1h06RVDIZ1f9xQbnKjONFoMILpTTpqJHdfO36oNLmpps/edit?usp=sharing)

```mermaid
%%{init: {'theme':'base'}}%%
flowchart LR
    subgraph " "
    v0["Reads"]
    v1["Kraken2 Database"]
    v3["GTDBTk Database"]
    end
    v5([QCONTROL])
    subgraph " "
    v6["Quality Control Reports"]
    v8["Trimmed Reads"]
    v10["MEGAHIT Contigs"]
    v12["QUAST Contigs Report"]
    v18["CheckM Quality Report"]
    v19["CheckM Plots"]
    v23["QUAST Bins Report"]
    v25["GTDBTk Taxonomic Annotation"]
    v26["GTDBTk Taxonomic Report"]
    v28["Kraken2 Classification"]
    v31["Bracken Species Abundance"]
    v32["Krona Visualization"]
    v39["Final Report"]
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
