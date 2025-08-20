// Define the `KRAKEN2` process that performs taxonomy analysis
process KRAKEN2 {
    container 'staphb/kraken2:latest'
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(is_single_end), val(sid), path(reads)
    path database
    val trigger
    
    output:
    tuple val(sid), path("${sid}_kraken2_result.txt"),      emit: result
    tuple val(sid), path("${sid}_kraken2_report.txt"),      emit: report
    
    script:
    def input_files = is_single_end ? "${reads}" : "${reads[0]},${reads[1]}"
    if (trigger) {
        """
        kraken2 \
        --db $database \
        --threads ${task.cpus} \
        --output ${sid}_kraken2_result.txt \
        --report ${sid}_kraken2_report.txt \
        --report-zero-counts \
        --use-names \
        --minimum-base-quality 20 \
        --gzip-compressed \
        ${input_files}
        """
    } else {
        """
        touch ${sid}_kraken2_result.txt
        touch ${sid}_kraken2_report.txt
        """
    }
    stub:
    """
    touch ${sid}_kraken2_result.txt
    touch ${sid}_kraken2_report.txt
    """
}
