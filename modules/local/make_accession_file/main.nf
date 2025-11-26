process MAKE_ACCESSION_FILE {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.container ? '' : 'bash:latest'}"

    input:
    tuple val(meta), val(refseq_id)

    output:
    tuple val(meta), path("*.txt"), emit: accession
    path "versions.yml",                       emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def filename = "${meta}.txt"
    """
    echo "${refseq_id}" > ${filename}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: \$(bash --version | head -n 1 | sed 's/.*version //')
    END_VERSIONS
    """

    stub:
    def filename = "${meta}.txt"
    """
    touch ${filename}

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        bash: "stub"
    END_VERSIONS
    """
}
