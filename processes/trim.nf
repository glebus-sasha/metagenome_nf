// Define the `TRIM` process that performs quality trimming and filtering of reads
process TRIM{
    container = 'nanozoo/fastp:0.23.1--9f2e255'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/reads_quality_control/before_after_trimming", pattern: '*.html'
//	  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads)

    output:
    tuple val(sid), path("${sid}_R1.fastq.gz"), path("${sid}_R2.fastq.gz"),     emit: trimmed_reads
    path '*.html',                                                              emit: html, optional: true
    path '*.json',                                                              emit: json, optional: true

    script:
    fq_1_trimmed = sid + '_R1.fastq.gz'
    fq_2_trimmed = sid + '_R2.fastq.gz'
    """
    fastp \
    --thread ${task.cpus} \
    --in1 ${reads[0]} \
    --in2 ${reads[1]}\
    --out1 $fq_1_trimmed \
    --out2 $fq_2_trimmed \
    --html ${sid}.fastp_stats.html \
    --json ${sid}.fastp_stats.json 
    """

    stub:
    """
    touch ${sid}.fastp_stats.html
    touch ${sid}.fastp_stats.json
    touch ${sid}_R1.fastq.gz
    touch ${sid}_R2.fastq.gz
    """
}
