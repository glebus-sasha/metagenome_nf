include { FASTQC                        } from '../modules/nf-core/fastqc'
include { FASTP                         } from '../modules/nf-core/fastp'
include { KRAKEN2_KRAKEN2               } from '../modules/nf-core/kraken2/kraken2'
include { BRACKEN_BRACKEN               } from '../modules/nf-core/bracken/bracken'


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
    ch_versions = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())
    
    /*input_fastqs          |
    QCONTROL & TRIM 
    KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db)
    BRACKEN(KRAKEN2.out.report, kraken2_db)
    METAPHLAN_RESULTS(METAPHLAN.out.txt)

    emit:
    fastqc              = QCONTROL.out.zip
    kreport             = KRAKEN2.out.report
    kresault            = KRAKEN2.out.result
    bracken             = BRACKEN.out.txt
    metaphlan           = METAPHLAN.out.txt*/
}