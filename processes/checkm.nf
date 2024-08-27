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
    # Оценка качества бинов и создание отчета
    checkm lineage_wf \
        -x fa \
        -t ${task.cpus} \
        ${bins} \
        ${sid}

    # Создание гистограммы GC и delta-GC графика
    checkm gc_plot \
        -x fa \
        ${bins} \
        ${sid}/gc_plot

    # Создание гистограммы плотности кодирующих областей и delta-CD графика
    checkm coding_plot \
        -x fa \
        ${bins} \
        ${sid}/coding_plot

    # Создание гистограммы расстояния тетрануклеотидов и delta-TD графика
    checkm tetra_plot \
        -x fa \
        ${bins} \
        ${sid}/tetra_plot

    # Создание изображения с GC, CD и TD распределением
    checkm dist_plot \
        -x fa \
        ${bins} \
        ${sid}/dist_plot

    # Создание Nx-графиков
    checkm nx_plot \
        -x fa \
        ${bins} \
        ${sid}/nx_plot

    # Создание гистограммы длины последовательностей
    checkm len_hist \
        -x fa \
        ${bins} \
        ${sid}/len_hist

    # Построение положения маркерных генов на последовательностях
    checkm marker_plot \
        -x fa \
        ${bins} \
        ${sid}/marker_plot

    # Построение покрытия бинов в зависимости от GC-содержания
    checkm gc_bias_plot \
        -x fa \
        ${bins} \
        ${sid}/gc_bias_plot
    """
}