#!/usr/bin/env nextflow
// Include processes
include { QCONTROL }            from './processes/qcontrol.nf'
include { TRIM }                from './processes/trim.nf'
include { KRAKEN2 }             from './processes/kraken2.nf'
include { BRACKEN }             from './processes/bracken.nf'
include { KRONA }               from './processes/krona.nf'
include { METASPADES }          from './processes/metaspades.nf'
include { MEGAHIT }             from './processes/megahit.nf'
include { ALIGN }               from './processes/align.nf'
include { METABAT2 }            from './processes/metabat2.nf'
include { CHECKM }              from './processes/checkm.nf'
include { QUAST }               from './processes/quast.nf'
include { GTDBTK }              from './processes/gtdbtk.nf'
include { REPORT }              from './processes/report.nf'

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

// Make the results directory if it needs
def result_dir = new File("${params.outdir}")
// result_dir.mkdirs()

// Define the input channel for FASTQ files, if provided
input_fastqs = Channel.fromFilePairs(["${params.reads}/*[rR]{1,2}*.*{fastq,fq}*", "${params.reads}/*_{1,2}.{fastq,fq}*"])

// Define the input channel for Kraken2 data base, if provided
kraken2_db = params.kraken2_db ? Channel.fromPath("${params.kraken2_db}").collect(): null

// Define the input channel for GTDB-TK data base, if provided
gtdbtk_db = params.gtdbtk_db ? Channel.fromPath("${params.gtdbtk_db}").collect(): null

workflow { 
    input_fastqs |
    QCONTROL & TRIM
    MEGAHIT(TRIM.out.trimmed_reads)
    TRIM.out.trimmed_reads.join(MEGAHIT.out.contigs) |
    ALIGN
    MEGAHIT.out.contigs.join(ALIGN.out.bam) |
    METABAT2 |
    CHECKM 
    METABAT2.out.bins |
        map { sid, bins_dir ->
            file(bins_dir).listFiles().findAll { it.name.endsWith('.fa') }.collect { bin_file ->
                [sid, bin_file]
            }
        }             |
        flatMap       |
        QUAST
    GTDBTK(METABAT2.out.bins, gtdbtk_db)
    KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    BRACKEN(KRAKEN2.out.sid, KRAKEN2.out.report, kraken2_db)
    KRONA(BRACKEN.out.sid, BRACKEN.out.txt)
    TRIM.out.json                  | 
        mix(QCONTROL.out.zip)      |
        mix(KRAKEN2.out.report)    |
        mix(QUAST.out.report)      |
        collect                    |
        REPORT
}





