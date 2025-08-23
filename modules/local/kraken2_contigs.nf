process KRAKEN2_CONTIGS {
    container 'staphb/kraken2:latest'
    tag "${sid}"
    errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(contigs)
    path database
    
    output:
    tuple val(sid), path("${sid}_kraken2_contig_result.txt"),      emit: result
    tuple val(sid), path("${sid}_kraken2_contig_report.txt"),      emit: report
    
    script:
    """
    kraken2 \
        --db $database \
        --threads ${task.cpus} \
        --output ${sid}_kraken2_contig_result.txt \
        --report ${sid}_kraken2_contig_report.txt \
        --report-zero-counts \
        --use-names \
        --minimum-base-quality 20 \
        $contigs
    """

    stub:
    """
    touch ${sid}_kraken2_contig_result.txt
    touch ${sid}_kraken2_contig_report.txt
    """
}
