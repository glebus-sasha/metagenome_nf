// Define the `METABAT2` process that performs binning contingencies to isolate metagenomic assemblies
process METABAT2 {
    container = 'nanozoo/metabat2:2.15--c1941c7'
    tag "${sid}"
    publishDir "${output_dir}/contig_assembly/draft_bins"
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
    """

    stub:
    """
    mkdir ${sid}_bins
    """
}
