// Define the `REPORT` process that performs report
process REPORT {
    container = 'staphb/multiqc:latest'
    tag "$fastp"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}", mode: "copy"
//	  debug true
    errorStrategy 'ignore'
    	
    input:
    path fastp
    path fastqc
    path kraken2

    output:
    path '*.html', emit: html

    script:
    """
    multiqc $fastp $fastqc $kraken2 -n "summary_report.html"
    """

    stub:
    """
    touch combined_report.html
    """
}