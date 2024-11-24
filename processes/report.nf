// Define the `REPORT` process that performs report
process REPORT {
    container = 'staphb/multiqc:latest'
    tag "$fastp"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}"
//	  debug true
    errorStrategy 'ignore'
    	
    input:
    path fastp
    path fastqc
    path bracken

    output:
    path 'multiqc_report.html', emit: html

    script:
    """
    multiqc $fastp $fastqc $bracken
    """

    stub:
    """
    touch multiqc_report.html
    """
}