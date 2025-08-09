process SAMPLE2MAKERS {
    container 'staphb/metaphlan-4.1.1'
    tag "${sid}"
    // errorStrategy 'ignore'
    cpus params.cpus
    
    input:
    tuple val(sid), path(bowtie2)
    path database
    
    output:
    tuple val(sid), path("${sid}.json.bz2")
    
    script:
    """
    sample2markers.py \
        --input $bowtie2 \
        -n ${task.cpus} \
        -d $database/mpa_vJan25_CHOCOPhlAnSGB_202503.pkl \
        --output_dir .
    """

    stub:
    """
    touch ${sid}.json.bz2
    """
}
