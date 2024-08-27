// Define the `METASPADES` process that performs assembling readings into contingencies
process METASPADES {
    container = 'cimendes/metaspades:11.10.2018-1'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/METASPADES"
//	debug true
//  errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    
    output:
    val "${sid}",                                                   emit: sid
    path "${sid}_metaspades",                                       emit: metaspades
    path "${sid}_metaspades/contigs.fasta",                         emit: contigs
    path "${sid}_metaspades/scaffolds.fasta",                       emit: scaffolds
    
    script:
    """
    spades.py \
        --meta \
        -1 ${reads1} \
        -2 ${reads2} \
        -t ${param.cpus} \
        -m ${param.memory} \
        -o ${sid}_metaspades
    """
}