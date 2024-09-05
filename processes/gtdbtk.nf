// Define the `GTDBTK ` process that performs taxonomy classification
process GTDBTK {
    container = 'ecogenomic/gtdbtk:2.4.0'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/GTDBTK"
//	debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
        
    input:
    val sid
    path bins
    path db
    
    output:
    val("${sid}"),          emit: sid
    path("${sid}"),         emit: result
    
    script:
    """
    export GTDBTK_DATA_PATH=${db}
    rename 's/\.fa$/.fna/' ${bins}/*.fa
    gtdbtk classify_wf --genome_dir ${bins} --out_dir ${sid} --cpus ${task.cpus} --mash_db ${db}
    """

    stub:
    """
    mkdir ${sid}
    """
}