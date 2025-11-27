                                                                                           
include { METAPHLAN_METAPHLAN                           } from '../../../modules/nf-core/metaphlan/metaphlan'
include { METAPHLAN_RESULTS                             } from '../../../modules/local/metaphlan_results'

workflow FASTQ_METAPHLAN {

    take:
    reads
    metaphlan_db
    
    main:
    ch_versions         = channel.empty()
    ch_multiqc_files    = channel.empty()

    //
    // MODULE: Run MetaPlAn
    //
    METAPHLAN_METAPHLAN (
        reads,
        metaphlan_db,
        false
    )
    ch_multiqc_files        = ch_multiqc_files.mix(METAPHLAN_METAPHLAN.out.profile.collect{ it -> it[1]} )
    ch_versions             = ch_versions.mix(METAPHLAN_METAPHLAN.out.versions.first())
    ch_metaphlan_profiles   = METAPHLAN_METAPHLAN.out.profile
    //
    // MODULE: Run MetaPlAn results
    //
    METAPHLAN_RESULTS (
        ch_metaphlan_profiles
    )
    ch_metaphlan_results = METAPHLAN_RESULTS.out.csv
    ch_versions = ch_versions.mix(METAPHLAN_RESULTS.out.versions.first())

    emit:
    metaphlan_results   = ch_metaphlan_results
    versions            = ch_versions
    multiqc_files       = ch_multiqc_files

}