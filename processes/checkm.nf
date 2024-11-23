// Define the `CHECKM` process that performs assessing the quality and integrity of bins
process CHECKM {
    container = 'nanozoo/checkm:1.1.3--c79a047'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/annotated_bins"
//	  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(bins)

    output:
    val "${sid}",               emit: sid
    path "${sid}/bins/",        emit: bins

    
    script:
    """
    # Assess bin quality with multithreading and create a report
    checkm lineage_wf \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}    
    """

    stub:
    """
    mkdir ${sid}
    """
}
