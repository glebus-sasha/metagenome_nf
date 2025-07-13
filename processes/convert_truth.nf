process CONVERT_TRUTH {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(truth_file)

    output:
    tuple val(sid), path("${sid}_truth.csv")

    
    script:
    """
    convert_truth ${truth_file} ${sid}_truth.csv
    """

    stub:
    """
    touch ${sid}_truth.csv
    """
}
