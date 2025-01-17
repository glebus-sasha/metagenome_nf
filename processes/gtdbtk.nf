// Define the `GTDBTK ` process that performs taxonomy classification
process GTDBTK {
    container 'glebusasha/my-gtdbtk:2.4.0'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/bins_taxonomy", pattern: '*.summary.tsv', mode: "copy"
//	debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(bins)
    path db
    
    output:
    val "${sid}",                               emit: sid
    path "${sid}.summary.tsv",                  emit: tsv

    
    script:
    """
    export GTDBTK_DATA_PATH=${db}
    gtdbtk classify_wf --genome_dir ${bins} --out_dir ${sid} --cpus ${task.cpus} --mash_db ${db} -x fa
    mv ${sid}/classify/*.summary.tsv ${sid}.summary.tsv
    """

    stub:
    """
    touch ${sid}.summary.tsv
    """
}
