process ALPHA_DIV {
    container 'glebusasha/compare_abundance:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(tax_file)

    output:
    path "*"

    
    script:
    """
    alpha_div ${tax_file} $sid
    """

    stub:
    """
    
    """
}
