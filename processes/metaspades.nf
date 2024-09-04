// Define the `METASPADES` process that performs assembling readings into contingencies
process METASPADES {
    container = 'cimendes/metaspades:11.10.2018-1'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/METASPADES"
//	debug true
//  errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    
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