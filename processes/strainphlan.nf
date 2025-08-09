process STRAINPHLAN {
    container 'staphb/metaphlan-4.1.1'
    tag "${sid}"
    // errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(markers)
    
    output:
    tuple val(sid), path("${sid}_clades.txt")
    
    script:
    """
    strainphlan -s $markers \
         -o . \
         -c t__SGB4933 \
         --phylophlan_mode fast \
         --nproc $task.cpus
    """

    stub:
    """
    touch ${sid}_clades.txt
    """
}
