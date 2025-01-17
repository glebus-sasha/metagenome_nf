// Define the `REPORT` process that performs report
process REPORT {
    container 'staphb/multiqc:latest'
    tag "all samples"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}", mode: "copy"
//	  debug true
    errorStrategy 'ignore'
    	
    input:
    path files

    output:
    path 'summary_report.html', emit: html

    script:
    """
    multiqc . -n "summary_report.html"
    """

    stub:
    """
    touch combined_report.html
    """
}