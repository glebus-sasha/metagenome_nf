process CONVERT_BRACKEN {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(bracken_file)

    output:
    tuple val(sid), path("${sid}_bracken.csv")

    
    script:
    """
    convert_bracken.R $bracken_file ${sid}_bracken.csv
    """

    stub:
    """
    touch ${sid}_bracken.csv
    """
}
