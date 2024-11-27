# metagenome_nf
Nextflow-based pipeline for metagenome analysis

make file path_config.py inside metagenome_nf folder
```
mkdir path_config.py
```

contain path_config.py
```
READS_FOLDER    = "<path/to/tmp/folder/reads>"
OUTPUT_FOLDER   = "<path/to/output>"
nextflow_path   = "<path/to/metagenome_nf>"
kraken2_db      = "<path/to/kraken2_db>"
GTDB_db         = "<path/to/GTDB_db/release>"

nextflow_command = ["nextflow", "run",
 "./main.nf", "-profile", "singularity",
    "--reads", READS_FOLDER,
    "--outdir", OUTPUT_FOLDER,
    "--kraken2_db", kraken2_db,
    "--gtdbtk_db", GTDB_db]
```

create /etc/systemd/system/metagenome_web.service
```
sudo nano /etc/systemd/system/metagenome_web.service
```
metagenome_web.service contains
```
[Unit]
Description=Metagenome Analysis Service
After=network.target

[Service]
User=genome
Group=genome
WorkingDirectory=<path/to/metagenome_nf>
Environment="PATH=/home/username/.sdkman/candidates/java/current/bin:/home/username/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/home/username/.local/bin/flask:/usr/local/bin/nextflow:/media/username/DATA/.reads_tmp:/media/username/DATA/output:/home/username/metagenome_nf"
Environment="NXF_SINGULARITY_CACHEDIR=</home/username/.singularity>"
ExecStart=/usr/bin/python3 /home/genome/metagenome_nf/server.py
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```
enable service
```
sudo systemctl enable metagenome_web.service
```



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
## Description

This pipeline is implemented in Nextflow and includes several stages for metagenomic data analysis:

- **QCONTROL (FastQC)**: Quality control of raw sequencing data using FastQC.
- **TRIM (fastp)**: Trimming of reads to remove adapters and low-quality sequences using fastp.
- **KRAKEN2 (Kraken2)**: Taxonomic classification of reads using Kraken2.
- **BRACKEN (Bracken)**: Estimation of species abundance based on Kraken2 outputs using Bracken.
- **METASPADES (metaSPAdes)**: Assembly of metagenomic sequences using metaSPAdes.
- **ALIGN (Bowtie2)**: Alignment of reads to the assembled contigs using BWA MEM.
- **METABAT (MetaBAT2)**: Binning of assembled contigs into metagenomic bins using MetaBAT2.
- **CHECKM (CheckM)**: Quality assessment and visualization of metagenomic bins using CheckM.
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
