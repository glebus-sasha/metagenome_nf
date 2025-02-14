// Define the `KRONA` process that performs taxonomy analysis
process KRONA {
    container 'nanozoo/krona:2.7.1--e7615f7'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/metagenome_taxonomy/visualisation", mode: "copy"
//	debug true
    errorStrategy 'ignore'
    
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