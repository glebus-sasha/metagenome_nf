// Define the `KRONA` process that performs taxonomy analysis
process KRONA {
    container 'nanozoo/krona:2.7.1--e7615f7'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(kraken)
    
    output:
    tuple val(sid), path("${sid}.html"), emit: html
    
    script:
    """
    ktImportTaxonomy -o ${sid}.html ${kraken}
    """

    stub:
    """
    touch ${sid}.html
    """
}