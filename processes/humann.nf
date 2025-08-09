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
    tuple val(sid), path("${sid}_genefamilies.tsv")
    tuple val(sid), path("${sid}_pathabundance.tsv")
    tuple val(sid), path("${sid}_pathcoverage.tsv")

    script:
    """
    humann \
        --input $reads \
        --output . \
        --nucleotide-database $nucleotide_database \
        --protein-database $protein_database \
        --metaphlan-options "--bowtie2db $metaphlan_database" \
        --threads ${task.cpus}
    """

    stub:
    """
    touch ${sid}_genefamilies.tsv
    touch ${sid}_pathabundance.tsv
    touch ${sid}_pathcoverage.tsv
    """
}
