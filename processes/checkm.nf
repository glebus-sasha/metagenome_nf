// Define the `CHECKM` process that performs assessing the quality and integrity of bins
process CHECKM {
    container = 'nanozoo/checkm:1.1.3--c79a047'
    tag "${sid}"
    publishDir "${params.outdir}/${workflow.start.format('yyyy-MM-dd_HH-mm-ss')}_${workflow.runName}/CHECKM"
//	  debug true
    errorStrategy 'ignore'
    cpus params.cpus

    input:
    val sid
    path bins

    output:
    val "${sid}", emit: sid
    path "${sid}", emit: reports

    
    script:
    """
    # Generate a quality assessment report
    checkm qa \
        -o 2 \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/qa_report

    # Create GC histogram and delta-GC plot
    checkm gc_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/gc_plot

    # Create coding density (CD) histogram and delta-CD plot
    checkm coding_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/coding_plot

    # Create tetranucleotide distance (TD) histogram and delta-TD plot
    checkm tetra_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/tetra_plot

    # Create image with GC, CD, and TD distribution plots together
    checkm dist_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/dist_plot

    # Create Nx-plots
    checkm nx_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/nx_plot

    # Create sequence length histogram
    checkm len_hist \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/len_hist

    # Plot position of marker genes on sequences
    checkm marker_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/marker_plot

    # Plot bin coverage as a function of GC content
    checkm gc_bias_plot \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}/gc_bias_plot
    
    # Assess bin quality with multithreading and create a report
    checkm lineage_wf \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}
    """
}