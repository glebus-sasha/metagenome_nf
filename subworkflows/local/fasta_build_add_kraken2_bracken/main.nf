include { KRAKEN2_ADD   } from '../../../modules/local/kraken2/add/main'
include { KRAKEN2_BUILD } from '../../../modules/local/kraken2/build/main'
include { BRACKEN_BUILD } from '../../../modules/local/bracken/build/main'


workflow FASTA_BUILD_ADD_KRAKEN2_BRACKEN {
    take:
    ch_fasta // channel: [ val(meta), [ fasta1, fasta2, fasta3] ]
    ch_taxonomy

    main:

    ch_versions = channel.empty()

    //
    // MODULE: Add FASTA files to  Kraken2 databases
    //
    KRAKEN2_ADD(
        ch_fasta,
        ch_taxonomy
    )
    ch_kraken2_db = KRAKEN2_ADD.out.kraken2_db
    ch_versions = ch_versions.mix(KRAKEN2_ADD.out.versions)
    //
    // MODULE: Build Kraken2 databases
    //
    KRAKEN2_BUILD(
        ch_kraken2_db
    )
    ch_kraken2_db = KRAKEN2_BUILD.out.db
    ch_versions = ch_versions.mix(KRAKEN2_BUILD.out.versions)
    //
    // MODULE: Build Bracken databases
    //
    BRACKEN_BUILD(
        ch_kraken2_db
    )
    ch_kraken2_db = BRACKEN_BUILD.out.db
    ch_versions = ch_versions.mix(BRACKEN_BUILD.out.versions)
    
    emit:
    versions    = ch_versions
    kraken2_db  = ch_kraken2_db
}
