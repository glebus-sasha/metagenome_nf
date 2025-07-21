process HUMANN {
    container 'biobakery/humann:3.9'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    // errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads)
    path nucleotide_database
    path protein_database
    path metaphlan_database

    output:
    path "*"

    script:
    """
    humann \
        --input $reads \
        --output humann_out \
        --nucleotide-database $nucleotide_database \
        --protein-database $protein_database \
        --metaphlan-options "--bowtie2db $metaphlan_database" \
        --threads ${task.cpus}
    """

    stub:
    """

    """
}
