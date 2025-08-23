process KRONA_METAPHLAN {
    container 'nanozoo/krona:2.7.1--e7615f7'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(metaphlan)
    
    output:
    tuple val(sid), path("${sid}.html"), emit: html
    
    script:
    """
    ktImportTaxonomy -o ${sid}.html ${metaphlan}
    """

    stub:
    """
    touch ${sid}.html
    """
}