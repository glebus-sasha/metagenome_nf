// Define the `QCONTROL` process that performs quality trimming and filtering of reads
process QCONTROL{
    container 'staphb/fastqc:0.12.1'
    errorStrategy 'ignore'

    input:
    tuple val(_is_single_end), val(sid), path(reads)

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
