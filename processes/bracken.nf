// Define the `BRACKEN` process that performs taxonomy analysis
process BRACKEN {
    container 'staphb/bracken:latest'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
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