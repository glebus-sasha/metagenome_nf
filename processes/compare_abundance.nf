process COMPARE_ABUDANCE {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(truth_file), path(kraken_file)

    output:
    path "*"

    
    script:
    """
    compare_abundance ${truth_file} ${kraken_file} $sid
    """

    stub:
    """
    
    """
}
