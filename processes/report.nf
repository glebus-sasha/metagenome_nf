process REPORT {
    container 'staphb/multiqc:latest'
    tag "all samples"
    errorStrategy 'ignore'
    	
    input:
    path files

    output:
    path 'summary_report.html', emit: html

    script:
    """
    cat <<EOF > multiqc_config.yaml
    module_config:
    kraken:
        top_n: 10
    EOF

    # 2. Запускаем MultiQC с указанием конфига
    multiqc . -n "summary_report.html" -c multiqc_config.yaml    
    """

    stub:
    """
    touch combined_report.html
    """
}