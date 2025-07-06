process CONVERT_METAPHLAN {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(metaphlan_file)

    output:
    tuple val(sid), path("${sid}_metaphlan.csv")

    
    script:
    """
    convert_metaphlan.R $metaphlan_file ${sid}_metaphlan.csv
    """

    stub:
    """
    touch ${sid}_metaphlan.csv
    """
}
