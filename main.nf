#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/metagenome
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/glebus-sasha/metagenome_nf
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { MULTIQC                       } from './modules/nf-core/multiqc'
include { FASTQ_TAXONOMY_PROD           } from './workflows/fastq_taxonomy_prod.nf'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    input_fastqs = Channel.fromPath("${params.reads}/*.[fq,fastq]*")
        .map { file ->
            def sampleName = file.simpleName.replaceFirst(/_[rR][12]$/, '')
            [sampleName, file]
        }
        .groupTuple()
        .map { sampleName, files ->
            def isSingleEnd = files.size() == 1
                        [
                [id: sampleName, single_end: isSingleEnd],
                files.sort()
            ]
        }

    // input_fastqs        = Channel.fromFilePairs(["${params.reads}/*[rR]{1,2}*.*{fastq,fq}*", "${params.reads}/*_{1,2}.{fastq,fq}*"])
    kraken2_db          = Channel.fromPath("${params.kraken2_db}").collect()
    metaphlan_db        = Channel.fromPath("${params.metaphlan_db}").collect()

    /*
    gtdbtk_db           = Channel.fromPath("${params.gtdbtk_db}").collect()
    metaphlan_db_old    = Channel.fromPath("${params.metaphlan_db_old}").collect()
    kneaddata_database  = Channel.fromPath("${params.kneaddata_database}").collect()
    nucleotide_database = Channel.fromPath("${params.nucleotide_database}").collect()
    protein_database    = Channel.fromPath("${params.protein_database}").collect()
    truth_tax           = Channel.fromPath("${params.truth_tax}/*.*tsv*").map { tuple(it.baseName, it) }
    ar122_file          = Channel.fromPath("${params.ar122_file}").collect()
    bac120_file         = Channel.fromPath("${params.bac120_file}").collect()
    */

    FASTQ_TAXONOMY_PROD (
        input_fastqs,
        kraken2_db,
        metaphlan_db
    )
    

    /*
    FASTQ_TAXONOMY_DEV (
        input_fastqs,
        kraken2_db,
        gtdbtk_db,
        metaphlan_db,
        metaphlan_db_old,
        kneaddata_database,
        nucleotide_database,
        protein_database
    )
    */

    /*
    compare_taxonomy(
        truth_tax,
        ar122_file,
        bac120_file,
        FASTQ_TAXONOMY.out.kresault,
        FASTQ_TAXONOMY.out.kresault_contigs,
        FASTQ_TAXONOMY.out.bracken,
        FASTQ_TAXONOMY.out.bracken_contigs,
        FASTQ_TAXONOMY.out.metaphlan,
        FASTQ_TAXONOMY.out.gtdbtk
    )
    */
    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = FASTQ_TAXONOMY_PROD.out.ch_multiqc_files.mix(FASTQ_TAXONOMY_PROD.out.ch_collated_versions)
    MULTIQC (
        ch_multiqc_files.collect(),
        [],
        [],
        [],
        [],
        []
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/