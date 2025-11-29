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
include { DOWNLOAD_FASTA_CREATE_KRAKEN_DB                   } from './subworkflows/local/download_fasta_create_kracken_db'
include { FASTQ_PREPARE                                     } from './subworkflows/local/fastq_prepare'
include { SHORTREAD_HOSTREMOVAL                             } from './subworkflows/local/shortread_hostremoval'
include { FASTQ_KRAKEN2_BRACKEN as BRACKEN_CUSTOM_READS     } from './subworkflows/local/fastq_kraken2_bracken'
include { FASTQ_KRAKEN2_BRACKEN as BRACKEN_CUSTOM_CONTIGS   } from './subworkflows/local/fastq_kraken2_bracken'
include { FASTQ_METAPHLAN                                   } from './subworkflows/local/fastq_metaphlan'
include { TAX_METRICS                                       } from './modules/local/tax_metrics'
include { MEGAHIT                                           } from './modules/nf-core/megahit'
include { GENOMAD_ENDTOEND                                  } from './modules/nf-core/genomad/endtoend/main.nf'
include { softwareVersionsToYAML                            } from './subworkflows/nf-core/utils_nfcore_pipeline'
include { MULTIQC                                           } from './modules/nf-core/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    ch_versions         = channel.empty()
    ch_multiqc_files    = channel.empty()
    ch_contigs          = channel.empty()
    input_fastqs        = channel.fromPath("${params.reads}/*.[fq,fastq]*")
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
    metaphlan_db            = channel.value(file(params.metaphlan_db))
    kraken2_db              = channel.value(file(params.kraken2_db))
    genomad_db              = channel.value(file(params.genomad_db))

    list_of_organisms       = channel.value(file(params.list_of_organisms))
    taxonomy                = channel.value(file(params.taxonomy))
    db_name                 = params.db_name

    host_reference          = channel.value(file(params.host_reference))
    host_reference_index    = channel.value(file(params.host_reference_index))

    if( params.run_download ) {
        //
        // SUBWORKFLOW: Download fasta and create kraken db
        //
        DOWNLOAD_FASTA_CREATE_KRAKEN_DB (
            list_of_organisms,
            taxonomy,
            db_name
        )
        ch_versions = ch_versions.mix(DOWNLOAD_FASTA_CREATE_KRAKEN_DB.out.versions.first())
        kraken2_db  = DOWNLOAD_FASTA_CREATE_KRAKEN_DB.out.kraken2_db
    } else {
        log.info "⏭ skip DOWNLOAD_FASTA_CREATE_KRAKEN_DB"
    }
    //
    // SUBWORKFLOW: Run fastq prepare
    //
    FASTQ_PREPARE (
        input_fastqs
    )
    ch_reads = FASTQ_PREPARE.out.reads
    ch_versions = ch_versions.mix(FASTQ_PREPARE.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(FASTQ_PREPARE.out.multiqc_files)
    //
    // SUBWORKFLOW: Run metaphlan
    //
    FASTQ_METAPHLAN (
        ch_reads,
        metaphlan_db
    )
    ch_metaphlan_results    = FASTQ_METAPHLAN.out.metaphlan_results
    ch_versions             = ch_versions.mix(FASTQ_METAPHLAN.out.versions.first())
    ch_multiqc_files        = ch_multiqc_files.mix(FASTQ_METAPHLAN.out.multiqc_files)
    //
    // MODULE: Run tax metrics
    //
    TAX_METRICS (
        ch_metaphlan_results
    )
    ch_versions = ch_versions.mix(TAX_METRICS.out.versions.first())
    if( params.run_hostremoval ) {
        //
        // SUBWORKFLOW: remove host reads
        //
        SHORTREAD_HOSTREMOVAL (
            ch_reads,
            host_reference,
            host_reference_index
        )
        ch_versions         = ch_versions.mix(SHORTREAD_HOSTREMOVAL.out.versions.first())
        ch_reads            = SHORTREAD_HOSTREMOVAL.out.reads
        ch_multiqc_files    = ch_multiqc_files.mix(SHORTREAD_HOSTREMOVAL.out.mqc)
    } else {
        log.info "⏭ skip SHORTREAD_HOSTREMOVAL"
    } 
    if( params.run_reads_kraken ) {
        //
        // SUBWORKFLOW: Run kraken2 and bracken
        //
        BRACKEN_CUSTOM_READS (
            ch_reads,
            kraken2_db
        )
        ch_versions      = ch_versions.mix(BRACKEN_CUSTOM_READS.out.versions.first())
        ch_multiqc_files = ch_multiqc_files.mix(BRACKEN_CUSTOM_READS.out.multiqc_files)
    } else {
        log.info "⏭ skip BRACKEN_CUSTOM_READS"
    }
    if( params.run_contigs_kraken || params.run_virus_taxonomy) {
        //
        // Assembly with MEGAHIT
        //
        ch_reads = ch_reads.map { meta, files -> [ meta, files[0], files[1] ]
        }
        MEGAHIT(
            ch_reads
        )
        ch_contigs  = MEGAHIT.out.contigs
        ch_versions = ch_versions.mix(MEGAHIT.out.versions)
    } else {
        log.info "⏭ skip MEGAHIT"
    }
    if( params.run_virus_taxonomy) {
        //
        // Generate contigs taxonomy with GENOMAD
        //
        GENOMAD_ENDTOEND(
            ch_contigs,
            genomad_db
        )
        ch_versions = ch_versions.mix(GENOMAD_ENDTOEND.out.versions)
    } else {
        log.info "⏭ skip GENOMAD"
    }
    if( params.run_contigs_kraken ) {
        //
        // SUBWORKFLOW: Run kraken2 and bracken on contigs
        //
        ch_contigs = ch_contigs.map { meta, file ->
        def new_meta = meta.clone()
        new_meta.single_end = true
        [ new_meta, file ]
        }      
        BRACKEN_CUSTOM_CONTIGS (
            ch_contigs,
            kraken2_db
        )
        ch_versions      = ch_versions.mix(BRACKEN_CUSTOM_CONTIGS.out.versions.first())
        ch_multiqc_files = ch_multiqc_files.mix(BRACKEN_CUSTOM_CONTIGS.out.multiqc_files)
    } else {
        log.info "⏭ skip BRACKEN_CUSTOM_CONTIGS"
    }
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'metagenome_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }
    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
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