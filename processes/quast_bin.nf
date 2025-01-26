// Define the `QUAST_BIN` process that performs assessing the quality and integrity of bins
process QUAST_BIN {
    container 'staphb/quast:5.3.0'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/bins_stats", mode: "copy"
//  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(bin)

    output:
    val "${sid}"                 , emit: sid
    path "${sid}/${bin.baseName}", emit: quast_results

    script:
    """
    quast.py \
        ${bin} \
        -o ${sid}/${bin.baseName} \
        -t ${task.cpus}
    """

    stub:
    """
    mkdir -p ${sid}/quast_results
    """
}
