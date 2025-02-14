// Define the `QCONTROL` process that performs quality trimming and filtering of reads
process QCONTROL{
    container 'staphb/fastqc:0.12.1'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/reads_quality_control/before_trimming", pattern: '*.html', mode: "copy"
//	debug true
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
