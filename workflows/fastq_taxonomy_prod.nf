/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT MODULES / SUBWORKFLOWS / FUNCTIONS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                        } from '../modules/nf-core/fastqc'
include { FASTP                         } from '../modules/nf-core/fastp'
include { KRAKEN2_KRAKEN2               } from '../modules/nf-core/kraken2/kraken2'
include { BRACKEN_BRACKEN               } from '../modules/nf-core/bracken/bracken'
include { KREPORT2MPA                   } from '../modules/local/kreport2mpa'
include { BRACKEN_RESULTS              } from '../modules/local/bracken_results'
include { METAPHLAN_METAPHLAN           } from '../modules/nf-core/metaphlan/metaphlan'
include { METAPHLAN_RESULTS             } from '../modules/local/metaphlan_results'
include { softwareVersionsToYAML        } from '../subworkflows/nf-core/utils_nfcore_pipeline'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow FASTQ_TAXONOMY_PROD { 
    take:
    input_fastqs
    kraken2_db
    metaphlan_db
   
    main:
    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        input_fastqs
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    //
    // MODULE: Run FastP
    //
    FASTP (
        input_fastqs,
        [],
        [],
        false,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect{it[1]})
    ch_versions = ch_versions.mix(FASTP.out.versions.first())
    //
    // MODULE: Run Kraken2
    //
    KRAKEN2_KRAKEN2 (
        FASTP.out.reads,
        kraken2_db,
        false,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(KRAKEN2_KRAKEN2.out.report.collect{it[1]})
    ch_versions = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())
    //
    // MODULE: Run Bracken
    //
    BRACKEN_BRACKEN (
        KRAKEN2_KRAKEN2.out.report,
        kraken2_db
    )
    ch_multiqc_files = ch_multiqc_files.mix(BRACKEN_BRACKEN.out.reports.collect{it[1]})
    ch_versions = ch_versions.mix(BRACKEN_BRACKEN.out.versions.first())
    //
    // MODULE: Run kreport2mpa
    //
    KREPORT2MPA (
        BRACKEN_BRACKEN.out.txt
    )
    ch_versions = ch_versions.mix(KREPORT2MPA.out.versions.first())    
    //
    // MODULE: Run Bracken results
    //
    BRACKEN_RESULTS (
        KREPORT2MPA.out.csv
    )
    ch_versions = ch_versions.mix(BRACKEN_RESULTS.out.versions.first())
    //
    // MODULE: Run MetaPlAn
    //
    METAPHLAN_METAPHLAN (
        FASTP.out.reads,
        metaphlan_db,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(METAPHLAN_METAPHLAN.out.profile.collect{it[1]})
    ch_versions = ch_versions.mix(METAPHLAN_METAPHLAN.out.versions.first())
    //
    // MODULE: Run MetaPlAn results
    //
    METAPHLAN_RESULTS (
        METAPHLAN_METAPHLAN.out.profile
    )
    ch_versions = ch_versions.mix(METAPHLAN_RESULTS.out.versions.first())
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

    emit:
    ch_multiqc_files        = ch_multiqc_files
    ch_collated_versions    = ch_collated_versions
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/