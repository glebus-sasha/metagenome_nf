// Define the `PROKKA` process that performs binning contingencies to isolate metagenomic assemblies
process PROKKA {
    container = 'nanozoo/prokka:1.14.6--c99ff65'
    tag ""
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/PROKKA"
//	  debug true
    errorStrategy 'ignore'

    input:
    val sid
    path contigs
    path bam

    output:
    val "${sid}", emit: sid
    path "${sid}_bins/*", emit: bins

    
    script:
    """
    metabat2 -i ${contigs} -a ${bam} -o "${sid}_bins/bin"
    """
}