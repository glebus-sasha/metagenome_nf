// Define the `METABAT` process that performs binning contingencies to isolate metagenomic assemblies
process METABAT
    container = 'nanozoo/metabat2:2.15--c1941c7'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/METABAT"
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