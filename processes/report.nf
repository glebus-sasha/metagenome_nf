// Define the `REPORT` process that performs report
process REPORT {
    container = 'staphb/multiqc:latest'
    tag "$flagstat"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/REPORT"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus
    memory params.memory
    	
    input:
    path fastp
    path fastqc
    path flagstat
    path whatshap

    output:
    path '*.html', emit: html

    script:
    """
    multiqc $fastqc $fastp $flagstat $whatshap
    """

    stub:
    """
    touch multiqc_report.html
    """
}