// Define the `KRAKEN2` process that performs taxonomy analysis
process KRAKEN2 {
    container = 'staphb/kraken2:latest'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/KRAKEN2"
//	debug true
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    path database
    val gtdbtk_finish_flag
    
    output:
    val(sid),                               emit: sid
    path("${sid}_kraken2_result.txt"),      emit: result
    path("${sid}_kraken2_report.txt"),      emit: report
    
    script:
    """
    kraken2 \
    --db $database \
    --threads ${task.cpus} \
    --output ${sid}_kraken2_result.txt \
    --report ${sid}_kraken2_report.txt \
    --report-zero-counts \
    --use-names \
    --paired \
    --minimum-base-quality 20 \
    --gzip-compressed \
    --threads ${task.cpus} \
    ${reads1} ${reads2}
    """

    stub:
    """
    touch ${sid}_kraken2_result.txt
    touch ${sid}_kraken2_report.txt
    """
}
