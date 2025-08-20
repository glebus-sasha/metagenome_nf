process BRACKEN {
    container 'staphb/bracken:latest'
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(kraken_report)
    path database

    
    output:
    tuple val(sid), path("${sid}_bracken_result.txt"),   emit: txt
    
    script:
    """
    bracken -d $database -i $kraken_report -o ${sid}_bracken_result.txt -r 150 -l S
    """

    stub:
    """
    touch ${sid}_bracken_result.txt
    """
}