// Define the `METASPADES` process that performs assembling readings into contingencies
process METASPADES {
    container 'cimendes/metaspades:11.10.2018-1'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/METASPADES", mode: "copy"
//	debug true
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    
    output:
    val "${sid}",                                        emit: sid
    path "${sid}",                                       emit: metaspades
    path "${sid}/contigs.fasta",                         emit: contigs
    path "${sid}/scaffolds.fasta",                       emit: scaffolds
    
    script:
    """
    spades.py \
        --meta \
        -1 ${reads1} \
        -2 ${reads2} \
        -t ${task.cpus} \
        -m 800 \
        -o ${sid}
    """

    stub:
    """
    mkdir ${sid}
    touch ${sid}/contigs.fasta
    touch ${sid}/scaffolds.fasta
    """
}