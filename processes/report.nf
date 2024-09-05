// Define the `REPORT` process that performs report
process REPORT {
    container = 'staphb/multiqc:latest'
    tag "$fastp"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/REPORT"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    	
    input:
    path fastp
    path fastqc
    path kraken2
    path bracken

    output:
    path '*.html', emit: html

    script:
    """
    multiqc $fastp $fastqc $kraken2 $bracken
    """

    stub:
    """
    touch multiqc_report.html
    """
}