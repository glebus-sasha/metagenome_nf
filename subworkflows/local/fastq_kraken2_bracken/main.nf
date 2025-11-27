                                                                                           
include { KRAKEN2_KRAKEN2   } from '../../../modules/nf-core/kraken2/kraken2'
include { BRACKEN_BRACKEN   } from '../../../modules/nf-core/bracken/bracken'
include { KREPORT2MPA       } from '../../../modules/local/kreport2mpa'
include { BRACKEN_RESULTS   } from '../../../modules/local/bracken_results'
workflow FASTQ_KRAKEN2_BRACKEN {

    take:
    ch_reads
    kraken2_db
    
    main:
    ch_versions         = channel.empty()
    ch_multiqc_files    = channel.empty()

    //
    // MODULE: Run Kraken2
    //
    KRAKEN2_KRAKEN2 (
        ch_reads,
        kraken2_db,
        false,
        false
    )
    ch_kreport = KRAKEN2_KRAKEN2.out.report
    ch_multiqc_files = ch_multiqc_files.mix(ch_kreport.collect{ it -> it[1]} )
    ch_versions      = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())
    //
    // MODULE: Run Bracken
    //
    BRACKEN_BRACKEN (
        ch_kreport,
        kraken2_db
    )
    ch_multiqc_files    = ch_multiqc_files.mix(BRACKEN_BRACKEN.out.reports.collect{ it -> it[1]} )
    ch_bracken_report   = BRACKEN_BRACKEN.out.txt
    ch_versions         = ch_versions.mix(BRACKEN_BRACKEN.out.versions.first())
    //
    // MODULE: Run kreport2mpa
    //
    KREPORT2MPA (
        ch_bracken_report
    )
    ch_versions      = ch_versions.mix(KREPORT2MPA.out.versions.first())
    ch_mpa_taxonomy = KREPORT2MPA.out.csv
    //
    // MODULE: Run Bracken Results
    //
    BRACKEN_RESULTS (
        ch_mpa_taxonomy
    )
    ch_versions = ch_versions.mix(BRACKEN_RESULTS.out.versions.first())

    emit:
    versions = ch_versions
    multiqc_files = ch_multiqc_files

}