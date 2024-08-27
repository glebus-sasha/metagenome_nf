// Define the `CHECKM` process that performs assessing the quality and integrity of bins
process CHECKM
    container = 'staphb/checkm:latest'
    tag ""
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/CHECKM"
//	  debug true
    errorStrategy 'ignore'

    input:
    val sid
    path bins

    output:
    val "${sid}", emit: sid
    path "*", emit: reports

    
    script:
    """
    checkm lineage_wf -x fa ${bins} .
    """
}