// Define the `ALIGN` process that aligns reads to the reference genome
process ALIGN {
    container 'glebusasha/bwa_samtools'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/other/aligments", mode: "copy"
//	  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads1), path(reads2), path(reference)

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
