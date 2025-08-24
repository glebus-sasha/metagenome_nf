process METAPHLAN_RESULTS {
    tag "$meta.id"
    label 'process_medium'

    conda "${moduleDir}/environment.yml"
    container 'glebussasha/tax_metrics:latest'

    input:
    tuple val(meta), path(metaphlan_file)

    output:
    tuple val(meta), path("*_taxonomy.csv")    , emit: csv
    path "versions.yml"                        , emit: versions
    
    when:
    task.ext.when == null || task.ext.when
    
    script:
    def args  = task.ext.args  ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    metaphlan_results \\
        $metaphlan_file \\
        ${prefix}_taxonomy.csv \\
        $args

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        cran-tidyverse: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('tidyverse')))")
    END_VERSIONS
    """

    stub:
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    touch ${prefix}_taxonomy.csv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        cran-tidyverse: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('tidyverse')))")
    END_VERSIONS
    """
}
