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
    path kraken2
    path config
    path logo

    output:
    path '*.html', emit: html

    script:
    """
    multiqc $fastp $fastqc $kraken2 -c $config
    """

    stub:
    """
    touch combined_report.html
    """
}