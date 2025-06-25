// Define the `GTDBTK ` process that performs taxonomy classification
process GTDBTK {
    container 'glebusasha/my-gtdbtk:2.4.0'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'
    cpus params.cpus

    input:
    tuple val(sid), path(bins)
    path db
    
    output:
    tuple val(sid), path("${sid}.summary.tsv"), emit: tsv

    
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
