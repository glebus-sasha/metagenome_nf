process CONVERT_KRAKEN {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(kraken_file)
    val tag

    output:
    tuple val(sid), path("${sid}_${tag}kraken.csv") 

    
    script:
    """
    convert_kraken $kraken_file ${sid}_${tag}kraken.csv
    """

    stub:
    """
    touch ${sid}_${tag}kraken.csv
    """
}
