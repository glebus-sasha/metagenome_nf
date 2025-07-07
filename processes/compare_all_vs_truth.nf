process COMPARE_ALL_VS_TRUTH {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(files)
    val(truth_name)

    output:
    path "*"

    
    script:
    """
    ENTREZ_KEY='f89d1708ce9e895b603000a05f2d17113507'
    compare_all_vs_truth . ${truth_name} $sid
    """

    stub:
    """
    mkdir results
    """
}
