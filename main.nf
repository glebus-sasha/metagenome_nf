#!/usr/bin/env nextflow
include { QCONTROL                      } from './processes/qcontrol.nf'
include { TRIM                          } from './processes/trim.nf'
include { METAPHLAN                     } from './processes/metaphlan.nf'
include { REPORT                        } from './processes/report.nf'
include { METAPHLAN_RESULTS             } from './processes/metaphlan_results.nf'

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
        }
    metaphlan_db        = Channel.fromPath("${params.metaphlan_db}")

    QCONTROL(input_fastqs)
    TRIM(input_fastqs)
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db) |
    METAPHLAN_RESULTS

    TRIM.out.json                                   |
        mix(QCONTROL.out.zip)                       |
        mix(METAPHLAN.out.txt.map{it[1]})           |
        collect                                     |
        REPORT
}