process METAPHLAN {
    container 'staphb/metaphlan:4.1.1'
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(is_single_end), val(sid), path(reads)
    path database
    
    output:
    tuple val(sid), path("${sid}.txt"), emit: txt
    
    script:
    def input_files = is_single_end ? "${reads}" : "${reads[0]},${reads[1]}"
    """
    metaphlan $input_files \
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
