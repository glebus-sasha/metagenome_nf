// Define the `METABAT2` process that performs binning contingencies to isolate metagenomic assemblies
process METABAT2 {
    container = 'nanozoo/metabat2:2.15--c1941c7'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/METABAT2"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory '60 GB'

    input:
    val sid
    path contigs
    path bam

    output:
    val "${sid}",           emit: sid
    path "${sid}_bins",     emit: bins

    
    script:
    """
    runMetaBat.sh -t ${task.cpus} ${contigs} ${bam} 
    mv final.contigs.fa.metabat* ${sid}_bins
    """

    stub:
    """
    mkdir ${sid}_bins
    """
}
