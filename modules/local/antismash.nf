process ANTISMASH {
    container 'nanozoo/antismash:8.0.0--b6973cb'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(fasta)

    output:
    path "*"

    script:
    """
    antismash $fasta \
    --cpus ${task.cpus} \
    --output-dir results/ \
    --genefinding-tool prodigal
    """

    stub:
    """

    """
}