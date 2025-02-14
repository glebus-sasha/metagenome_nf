// Define the `METABAT2` process that performs binning contingencies to isolate metagenomic assemblies
process METABAT2 {
    container 'nanozoo/metabat2:2.15--c1941c7'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${params.launch_name}/contig_assembly/draft_bins", mode: "copy"
//	  debug true
    errorStrategy 'ignore'

    input:
    tuple val(sid), path(contigs), path(bam)

    output:
    tuple val("${sid}"), path("${sid}_bins"),     emit: bins

    
    script:
    """
    runMetaBat.sh -t ${task.cpus} ${contigs} ${bam} 
    mv ${sid}.contigs.fa.metabat* ${sid}_bins
    for file in ${sid}_bins/*; do
        mv "\$file" "${sid}_bins/${sid}_\$(basename "\$file")"
    done
    """

    stub:
    """
    mkdir ${sid}_bins
    """
}
