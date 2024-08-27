// Define the `CHECKM` process that performs assessing the quality and integrity of bins
process CHECKM {
    container = 'nanozoo/checkm:1.1.3--c79a047'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/CHECKM"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus

    input:
    val sid
    path bins

    output:
    val "${sid}", emit: sid
    path "${sid}", emit: reports

    
    script:
    """
    checkm lineage_wf \
    -x fa \
    -t ${task.cpus} \
    ${bins} \
    ${sid}
    """
}