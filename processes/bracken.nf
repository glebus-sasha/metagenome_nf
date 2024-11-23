// Define the `BRACKEN` process that performs taxonomy analysis
process BRACKEN {
    container = 'staphb/bracken:latest'
    tag "${sid}"
    publishDir "${output_dir}/kraken_taxonomy/bracken"
//	debug true
    errorStrategy 'ignore'
    
    input:
    val sid 
    path kraken_report
    path database

    
    output:
    val "${sid}",                       emit: sid
    path "${sid}_bracken_result.txt",   emit: txt
    
    script:
    """
    bracken -d $database -i $kraken_report -o ${sid}_bracken_result.txt -r 100 -l S
    """

    stub:
    """
    touch ${sid}_bracken_result.txt
    """
}