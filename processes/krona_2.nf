// Define the `KRONA` process that performs taxonomy analysis
process KRONA_2 {
    container = 'nanozoo/krona:2.7.1--e7615f7'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/KRONA_2"
//	debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    
    input:
    val sid
    path kraken
    
    output:
    val("${sid}"),              emit: sid
    path("${sid}.html"),        emit: html
    
    script:
    """
    ktImportTaxonomy -o ${sid}.html ${kraken}
    """

    stub:
    """
    touch ${sid}.html
    """
}