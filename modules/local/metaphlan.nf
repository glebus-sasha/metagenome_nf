process METAPHLAN {
    container 'staphb/metaphlan-4.1.1'
    tag "${sid}"
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    path database
    
    output:
    tuple val(sid), path("${sid}.txt")          , emit: txt
    tuple val(sid), path("${sid}.bowtie2.bz2")  , emit: bowtie2
    tuple val(sid), path("${sid}.sam.bz2")      , emit: sam_bz
    
    script:
    """
    metaphlan $reads1,$reads2 \
        --input_type fastq \
        --bowtie2db $database \
        --bowtie2out ${sid}.bowtie2.bz2 \
        --samout ${sid}.sam.bz2 \
        --nproc ${task.cpus} \
        -o ${sid}.txt
    """

    stub:
    """
    touch ${sid}.txt
    touch ${sid}.bowtie2.bz2
    touch ${sid}.sam.bz2
    """
}
