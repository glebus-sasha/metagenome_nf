process METAPHLAN_CONTIGS {
    container 'staphb/metaphlan:4.1.1'
    tag "${sid}"
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(contigs)
    path database
    
    output:
    tuple val(sid), path("${sid}_contigs.txt"), emit: txt
    
    script:
    """
    metaphlan $contigs \
        --input_type fasta \
        --bowtie2db $database \
        --nproc ${task.cpus} \
        -o ${sid}_contigs.txt
    """

    stub:
    """
    touch ${sid}.txt
    """
}
