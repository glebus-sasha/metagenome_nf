process CONVERT_KRAKEN {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(kraken_file)

    output:
    tuple val(sid), path("${sid}_kraken.csv")

    
    script:
    """
    convert_kraken.R $kraken_file ${sid}_kraken.csv
    """

    stub:
    """
    touch ${sid}_kraken.csv
    """
}
