// Define the `KRAKEN2` process that performs taxonomy analysis
process KRAKEN2 {
    container 'staphb/kraken2:latest'
    tag "${sid}"
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    path database
    
    output:
    tuple val(sid), path("${sid}_kraken2_result.txt"),      emit: result
    tuple val(sid), path("${sid}_kraken2_report.txt"),      emit: report
    
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
