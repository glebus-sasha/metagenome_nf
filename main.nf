#!/usr/bin/env nextflow
include { REPORT                        } from './processes/report.nf'
include { FASTQ_TAXONOMY                } from './subworkflows/fastq_taxonomy.nf'
include { compare_taxonomy              } from './workflows/compare_taxonomy.nf'

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

def result_dir      = new File("${params.outdir}")
input_fastqs        = Channel.fromFilePairs(["${params.reads}/*[rR]{1,2}*.*{fastq,fq}*", "${params.reads}/*_{1,2}.{fastq,fq}*"])
kraken2_db          = Channel.fromPath("${params.kraken2_db}").collect()
gtdbtk_db           = Channel.fromPath("${params.gtdbtk_db}").collect()
metaphlan_db_old    = Channel.fromPath("${params.metaphlan_db_old}").collect()
metaphlan_db        = Channel.fromPath("${params.metaphlan_db}").collect()
kneaddata_database  = Channel.fromPath("${params.kneaddata_database}").collect()
nucleotide_database = Channel.fromPath("${params.nucleotide_database}").collect()
protein_database    = Channel.fromPath("${params.protein_database}").collect()
truth_tax           = Channel.fromPath("${params.truth_tax}/*.*tsv*").map { tuple(it.baseName, it) }
ar122_file          = Channel.fromPath("${params.ar122_file}").collect()
bac120_file         = Channel.fromPath("${params.bac120_file}").collect()

workflow {
    FASTQ_TAXONOMY(
        input_fastqs,
        kraken2_db,
        gtdbtk_db,
        metaphlan_db,
        metaphlan_db_old,
        kneaddata_database,
        nucleotide_database,
        protein_database
    )
    
    /*compare_taxonomy(
        truth_tax,
        ar122_file,
        bac120_file,
        FASTQ_TAXONOMY.out.kresault,
        FASTQ_TAXONOMY.out.kresault_contigs,
        FASTQ_TAXONOMY.out.bracken,
        FASTQ_TAXONOMY.out.bracken_contigs,
        FASTQ_TAXONOMY.out.metaphlan,
        FASTQ_TAXONOMY.out.gtdbtk
    )*/

    REPORT(
        FASTQ_TAXONOMY.out.fastqc.map{it[1]}                    |
            /*mix(FASTQ_TAXONOMY.out.kreport.map{it[1]})          |
            mix(FASTQ_TAXONOMY.out.kreport_contigs.map{it[1]})  |
            mix(FASTQ_TAXONOMY.out.quast)                       |
            mix(FASTQ_TAXONOMY.out.quast_bin)                   |
            mix(FASTQ_TAXONOMY.out.metaphlan.map{it[1]})        |
            mix(FASTQ_TAXONOMY.out.gtdbtk.map{it[1]})           |*/
            collect
    )
}