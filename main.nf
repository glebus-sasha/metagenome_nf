#!/usr/bin/env nextflow
include { QCONTROL                      } from './processes/qcontrol.nf'
include { TRIM                          } from './processes/trim.nf'
include { METAPHLAN                     } from './processes/metaphlan.nf'
include { REPORT                        } from './processes/report.nf'
include { METAPHLAN_RESULTS             } from './processes/metaphlan_results.nf'

include { KRAKEN2                       } from './processes/kraken2.nf'
include { BRACKEN                       } from './processes/bracken.nf'
include { UNIFY_RESULTS                 } from './processes/unify_results.nf'


workflow { 

    // Logging pipeline information
    log.info """\
    \033[0;36m  ==========================================  \033[0m
    \033[0;34m              M E T A G E N O M E             \033[0m
    \033[0;36m  ==========================================  \033[0m

        reads:      ${params.reads}
        outdir:     ${params.outdir}
        workDir:    ${workflow.workDir}
        """
        .stripIndent(true)

    input_fastqs = Channel.fromFilePairs([
        "${params.reads}/*[rR]{1,2}*.{fastq,fq}*",
        "${params.reads}/*_{1,2}.{fastq,fq}*",
        "${params.reads}/*.{fastq,fq}*"
    ], size: -1).map { sid, reads -> 
            def is_single_end = reads.size() == 1
            [is_single_end, sid, reads]
        }.first()

    metaphlan_db      = Channel.fromPath("${params.metaphlan_db}")
    kraken2_db        = Channel.fromPath("${params.kraken2_db}")
    
    QCONTROL(input_fastqs)
    TRIM(input_fastqs)
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db) |
    METAPHLAN_RESULTS
    
    is_empty = METAPHLAN_RESULTS.out.splitCsv(header: true).toList().map { it.isEmpty() }

    is_empty.branch { empty ->
        empty: empty
        non_empty: !empty
    }.set { check_result }

    check_result.empty.set { empty_trigger }
    KRAKEN2(input_fastqs, kraken2_db, empty_trigger)
    BRACKEN(KRAKEN2.out.report, kraken2_db)

    // Правильное создание каналов
    metaphlan_channel = check_result.non_empty.combine(METAPHLAN_RESULTS.out)
    bracken_channel = check_result.empty.combine(BRACKEN.out)

    // Объединяем каналы
    final_results = metaphlan_channel.mix(bracken_channel).map{[it[1], it[2]]}
final_results.view()
    UNIFY_RESULTS(final_results)


    TRIM.out.json |
        mix(QCONTROL.out.zip) |
        collect |
        REPORT
}