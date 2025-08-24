process KREPORT2MPA {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'biocontainers/krakentools:1.2.1--pyh7e72e81_0'

    input:
    tuple val(meta), path(bracken_file)

    output:
    tuple val(meta), path("*_mpa_taxonomy.csv")    , emit: csv
    path "versions.yml"                            , emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args  = task.ext.args  ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}_mpa_taxonomy"
    """
    kreport2mpa.py \\
        -r $bracken_file \\
        -o ${prefix}.csv \\
        $args

    KRAKEN_TOOLS_VERSION=\$(python -c "import sys; sys.path.insert(0, '/path/to/KrakenTools'); from kreport2mpa import __version__; print(__version__)" 2>/dev/null || echo "unknown")

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //')
        krakentools: \${KRAKEN_TOOLS_VERSION}
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}_mpa_taxonomy"
    """
    touch ${prefix}.csv

    KRAKEN_TOOLS_VERSION=\$(python -c "import sys; sys.path.insert(0, '/path/to/KrakenTools'); from kreport2mpa import __version__; print(__version__)" 2>/dev/null || echo "unknown")

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //')
        krakentools: \${KRAKEN_TOOLS_VERSION}
    END_VERSIONS
    """
}
