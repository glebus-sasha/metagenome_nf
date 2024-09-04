// Define the `MEGAHIT` process that performs assembling readings into contingencies
process MEGAHIT {
    container = 'cimendes/metaspades:11.10.2018-1'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/MEGAHIT"
//	debug true
//  errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    
    output:
    val "${sid}",                                                   emit: sid
    path "${sid}",                                                  emit: megahit
    
    script:
    """
    megahit -1 ${reads1} -2 ${reads2} -o ${sid}
    """

    stub:
    """
    mkdir ${sid}
    """
}