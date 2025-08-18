process METAPHLAN_RESULTS {
    container 'glebusasha/compare_abundance:latest'
    //errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(metaphlan_file)

    output:
    tuple val(sid), path("${sid}_taxonomy.csv")

    
    script:
    """
    metaphlan_results $metaphlan_file ${sid}_taxonomy.csv
    """

    stub:
    """
    touch ${sid}_taxonomy.csv
    """
}
