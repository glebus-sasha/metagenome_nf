// Define the `MEGAHIT` process that performs assembling readings into contingencies
process MEGAHIT {
    container = 'nanozoo/megahit:1.2.9--87c4487'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/MEGAHIT"
//	debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    
    output:
    val "${sid}",                                                   emit: sid
    path "${sid}",                                                  emit: megahit
    path "${sid}/final.contigs.fa",                                 emit: contigs
    
    script:
    """
    megahit -1 ${reads1} -2 ${reads2} -o ${sid}
    """

    stub:
    """
    mkdir ${sid}
    touch ${sid}/final.contigs.fa
    """
}