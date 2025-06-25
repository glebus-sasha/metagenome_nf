// Define the `PROKKA` process that performs binning contingencies to isolate metagenomic assemblies
process PROKKA {
    container 'nanozoo/prokka:1.14.6--c99ff65'
    tag { 
        sid.length() > 40 ? "${sid.take(20)}...${sid.takeRight(20)}" : sid
    }
    errorStrategy 'ignore'
    
    input:
    val sid
    path contigs
    path bam

    output:
    val "${sid}",               emit: sid
    path "${sid}_bins/*",       emit: bins

    
    script:
    """
    prokka --outdir bin1_annotation --prefix bin1 bins/bin.1.fa
    """

    stub:
    """

    """
}