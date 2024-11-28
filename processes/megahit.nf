// Define the `MEGAHIT` process that performs assembling readings into contingencies
process MEGAHIT {
    container = 'nanozoo/megahit:1.2.9--87c4487'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/contigs", pattern: '*.contigs.fa', mode: "copy"
//	debug true
    errorStrategy 'ignore'
    
    input:
    tuple val(sid), path(reads1), path(reads2)
    
    output:
    tuple val("${sid}"), path("${sid}"),                            emit: megahit
    tuple val("${sid}"), path("${sid}.contigs.fa"),                 emit: contigs
    
    script:
    """
    megahit -1 ${reads1} -2 ${reads2} -o ${sid} -t ${task.cpus}
    mv ${sid}/final.contigs.fa  ${sid}.contigs.fa 
    """

    stub:
    """
    mkdir ${sid}
    touch ${sid}/final.contigs.fa
    """
}