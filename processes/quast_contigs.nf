// Define the `QUAST_CONTIGS` process that performs assessing the quality and integrity of contigs
process QUAST_CONTIGS {
    container 'staphb/quast:5.3.0'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/contigs_stats", mode: "copy"
//  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(contigs)

    output:
    val "${sid}" , emit: sid
    path "${sid}", emit: quast_results

    script:
    """
    quast.py \
        ${contigs} \
        -o ${sid} \
        -t ${task.cpus}
    """

    stub:
    """
    mkdir -p ${sid}/quast_results
    """
}
