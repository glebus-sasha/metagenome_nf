// Define the `PROKKA` process that performs binning contingencies to isolate metagenomic assemblies
process PROKKA {
    container = 'nanozoo/prokka:1.14.6--c99ff65'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/PROKKA"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    
    input:
    val sid
    path contigs
    path bam

    output:
    val "${sid}",               emit: sid
    path "${sid}_bins/*",       emit: bins

    
    script:
    """
    prokka --outdir bin1_annotation --prefix bin1 bins/bin.1.fa
    """

    stub:
    """

    """
}