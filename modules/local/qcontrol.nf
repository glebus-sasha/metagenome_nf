// Define the `QCONTROL` process that performs quality trimming and filtering of reads
process QCONTROL{
    container 'staphb/fastqc:0.12.1'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(reads)

    output:
    path "*.html",  emit: html
    path "*.zip",   emit: zip
    
    script:
    """
    fastqc $reads
    """

    stub:
    """
    touch ${sid}.html
    touch ${sid}.zip
    """
}
