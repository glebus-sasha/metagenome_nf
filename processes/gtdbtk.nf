// Define the `GTDBTK ` process that performs taxonomy classification
process GTDBTK {
    container = 'nanozoo/gtdbtk:2.4.0--02c00d5'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/GTDBTK"
//	debug true
//    errorStrategy 'ignore'
    
    input:
    val sid
    path bins
    
    output:
    val(sid), emit: sid
    path("${sid}"), emit: result
    
    script:
    """
    gtdbtk classify_wf --genome_dir ${bins} --out_dir ${sid} --cpus ${task.cpus} --skip_ani_screen
    """

    stub:
    """
    mkdir ${sid}
    """
}