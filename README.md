# metagenome_nf
Nextflow-based pipeline for metagenome analysis

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
