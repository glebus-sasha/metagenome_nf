// Define the `CHECKM` process that performs assessing the quality and integrity of bins
process CHECKM {
    container 'nanozoo/checkm:1.1.3--c79a047'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
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
    mkdir ${sid}/bins/
    """
}
