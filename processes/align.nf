// Define the `ALIGN` process that aligns reads to the reference genome
process ALIGN {
    container = 'glebusasha/bwa_samtools'
    tag "$reference ${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/ALIGN"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory '60 GB'

    input:
    tuple val(sid), path(reads1), path(reads2)
    tuple val(sid), path(reference)

    output:
    tuple val(sid), path("*.sorted.bam"),    emit: bam
    
    script:
    """
        bwa index ${reference}
        bwa mem \
            -t ${task.cpus} ${reference} ${reads1} ${reads2} | \
        samtools view -bh | \
        samtools sort -o ${sid}.sorted.bam

    """

    stub:
    """
    touch ${sid}.sorted.bam
    """
}
