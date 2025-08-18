process METAPHLAN {
    container 'staphb/metaphlan:4.1.1'
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    path database
    
    output:
    tuple val(sid), path("${sid}.txt"), emit: txt
    
    script:
    """
    metaphlan $reads1,$reads2 \
        --input_type fastq \
        --bowtie2db $database \
        --bowtie2out ${sid}.bowtie2.bz2 \
        --nproc ${task.cpus} \
        -o ${sid}.txt
    """

    stub:
    """
    touch ${sid}.txt
    """
}
