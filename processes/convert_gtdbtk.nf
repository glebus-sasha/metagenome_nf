process CONVERT_GTDBTK {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(gtdbtk_file)
    path(ar122_file)
    path(bac120_file)

    output:
    tuple val(sid), path("${sid}_gtdbtk.csv")

    
    script:
    """
    convert_gtdbtk $gtdbtk_file $ar122_file $bac120_file ${sid}_gtdbtk.csv
    """

    stub:
    """
    touch ${sid}_gtdbtk.csv
    """
}
