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
result_dir.mkdirs()

// Define the input channel for FASTQ files, if provided
input_fastqs = params.reads ? Channel.fromFilePairs("${params.reads}/*[12].{fastq,fq,fastq.gz,fq.gz}", checkIfExists: true) : null

// Define the input channel for Kraken2 data base, if provided
kraken2_db = params.kraken2_db ? Channel.fromPath("${params.kraken2_db}").collect(): null

// Define the input channel for GTDB-TK data base, if provided
gtdbtk_db = params.gtdbtk_db ? Channel.fromPath("${params.gtdbtk_db}").collect(): null

// Define the workflow
workflow { 
    QCONTROL(input_fastqs)
    TRIM(input_fastqs)
    KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    BRACKEN(KRAKEN2.out.sid, KRAKEN2.out.report, kraken2_db)
    KRONA(BRACKEN.out.sid, BRACKEN.out.txt)
//    METASPADES(TRIM.out.trimmed_reads)
    MEGAHIT(TRIM.out.trimmed_reads)
    ALIGN(TRIM.out.trimmed_reads, MEGAHIT.out.contigs)
    METABAT2(ALIGN.out.sid, MEGAHIT.out.contigs, ALIGN.out.bam)
    CHECKM(METABAT2.out.sid, METABAT2.out.bins)
    GTDBTK(METABAT2.out.sid, METABAT2.out.bins, gtdbtk_db)
    REPORT(TRIM.out.json.collect(), QCONTROL.out.zip.collect(), KRAKEN2.out.report.collect(), BRACKEN.out.txt.collect())

    // Make the pipeline reports directory if it needs
    if ( params.reports ) {
        def pipeline_report_dir = new File("${params.outdir}/pipeline_info/")
        pipeline_report_dir.mkdirs()
    }
    // Create the symbolic link after the final process
    script:
    """
    ln -sfn "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}" "${params.outdir}/latest"
    """
}




