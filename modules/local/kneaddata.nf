process KNEADDATA {
    container 'biobakery/kneaddata:0.10.0'
    tag {
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    //errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads1), path(reads2)
    path database

    output:
    tuple val(sid), path("${sid}.fastq.gz")

    script:
    """
    kneaddata \
        --input ${reads1} \
        --input ${reads2} \
        -db ${database} \
        -o clean_reads \
        --threads ${task.cpus}
    cat clean_reads/*paired_*.fastq clean_reads/*unmatched_*.fastq | gzip > ${sid}.fastq.gz
    """

    stub:
    """
    mkdir clean_reads
    touch ${sid}.fastq.gz
    """
}