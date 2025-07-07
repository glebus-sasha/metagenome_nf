process CONVERT_BRACKEN {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(bracken_file)
    val(tag)

    output:
    tuple val(sid), path("${sid}_${tag}bracken.csv")

    
    script:
    """
    convert_bracken $bracken_file ${sid}_${tag}bracken.csv
    """

    stub:
    """
    touch ${sid}_${tag}bracken.csv 
    """
}
