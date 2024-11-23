// Define the `REPORT` process that performs report
process REPORT {
    container = 'staphb/multiqc:latest'
    tag "$fastp"
    publishDir "${output_dir}"
//	  debug true
    errorStrategy 'ignore'
    	
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