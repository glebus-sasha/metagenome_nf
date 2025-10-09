process KRAKENUNIQ {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/krakenuniq:1.0.4--pl5321h6dccd9a_2'
        : 'biocontainers/krakenuniq:1.0.4--pl5321h6dccd9a_2'}"

    input:
    // We stage sequencing files in a sub-directory so we don't accidentally gzip them later.
    tuple val(meta), path(input)
    val sequence_type
    path db
    val save_output_reads
    val report_file
    val save_output

    output:
    tuple val(meta), path("*.classified.${sequence_type}.gz"), optional: true, emit: classified_reads
    tuple val(meta), path("*.unclassified.${sequence_type}.gz"), optional: true, emit: unclassified_reads
    tuple val(meta), path('*.krakenuniq.classified.txt'), optional: true, emit: classified_assignment
    tuple val(meta), path('*.krakenuniq.report.txt'), emit: report
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    assert sequence_type in ['fasta', 'fastq']

    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def preload_mode = !task.ext.args.toString().contains('--preload-size')
    def preload_cmd = preload_mode ? "krakenuniq ${args} --db ${db} --preload --threads ${task.cpus}" : ''

    classified = meta.single_end ? "\${PREFIX}.classified.${sequence_type}" : "\${PREFIX}.merged.classified.${sequence_type}"
    unclassified = meta.single_end ? "\${PREFIX}.unclassified.${sequence_type}" : "\${PREFIX}.merged.unclassified.${sequence_type}"
    classified_option = save_output_reads ? "--classified-out \"${classified}\"" : ''
    unclassified_option = save_output_reads ? "--unclassified-out \"${unclassified}\"" : ''
    def output_option = save_output ? '--output "\${PREFIX}.krakenuniq.classified.txt"' : ''
    def report = report_file ? '--report-file "\${PREFIX}.krakenuniq.report.txt"' : ''
    compress_reads_command = save_output_reads ? "find . -maxdepth 0 -name '*.${sequence_type}' -print0 | xargs -0 -t -P ${task.cpus} -I % gzip --no-name %" : ''

    if (meta.single_end) {

        """
        ${preload_cmd}

        krakenuniq \\
            --db ${db} \\
            --threads ${task.cpus} \\
            ${report} \\
            ${output_option} \\
            ${unclassified_option} \\
            ${classified_option} \\
            ${args2} \\
            $input


        ${compress_reads_command}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            krakenuniq: \$(echo \$(krakenuniq --version 2>&1) | sed 's/^.*KrakenUniq version //; s/ .*\$//')
        END_VERSIONS
        """
    }
    else {
        """
        ${preload_cmd}

        krakenuniq \\
            --db ${db} \\
            --threads ${task.cpus} \\
            ${report} \\
            ${output_option} \\
            ${unclassified_option} \\
            ${classified_option} \\
            --paired \\
            ${args2} \\
            $input

        ${compress_reads_command}

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            krakenuniq: \$(echo \$(krakenuniq --version 2>&1) | sed 's/^.*KrakenUniq version //; s/ .*\$//')
        END_VERSIONS
        """
    }

    stub:
    assert sequence_type in ['fasta', 'fastq']

    def args = task.ext.args ?: ''
    def args2 = task.ext.args ?: ''
    def preload_mode = !task.ext.args.toString().contains('--preload-size')
    def preload_cmd = preload_mode ? "echo krakenuniq ${args} --db ${db} --preload --threads ${task.cpus}" : ''

    classified = meta.single_end ? "\${PREFIX}.classified.${sequence_type}" : "\${PREFIX}.merged.classified.${sequence_type}"
    unclassified = meta.single_end ? "\${PREFIX}.unclassified.${sequence_type}" : "\${PREFIX}.merged.unclassified.${sequence_type}"
    classified_option = save_output_reads ? "--classified-out \"${classified}\"" : ''
    unclassified_option = save_output_reads ? "--unclassified-out \"${unclassified}\"" : ''
    def output_option = save_output ? '--output "\${PREFIX}.krakenuniq.classified.txt"' : ''
    def report = report_file ? '--report-file "\${PREFIX}.krakenuniq.report.txt"' : ''
    compress_reads_command = save_output_reads ? "find . -name '*.${sequence_type}' -print0 | xargs -0 -t -P ${task.cpus} -I % gzip --no-name %" : ''
    if (meta.single_end) {

        """
        ${preload_cmd}

        create_file() {
            echo '<3 nf-core' > "\$1"
        }

        create_gzip_file() {
            echo '<3 nf-core' | gzip -n > "\$1"
        }

        echo krakenuniq \\
            --db ${db} \\
            --threads ${task.cpus} \\
            ${report} \\
            ${output_option} \\
            ${unclassified_option} \\
            ${classified_option} \\
            ${args2} \\
            $input

            create_file "\${PREFIX}.krakenuniq.classified.txt"
            create_file "\${PREFIX}.krakenuniq.report.txt"
            create_gzip_file "\${PREFIX}.classified.${sequence_type}.gz"
            create_gzip_file "\${PREFIX}.unclassified.${sequence_type}.gz"


        echo "${compress_reads_command}"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            krakenuniq: \$(echo \$(krakenuniq --version 2>&1) | sed 's/^.*KrakenUniq version //; s/ .*\$//')
        END_VERSIONS
        """
    }
    else {
        """
        ${preload_cmd}

        create_file() {
            echo '<3 nf-core' > "\$1"
        }

        create_gzip_file() {
            echo '<3 nf-core' | gzip -n > "\$1"
        }

        echo krakenuniq \\
            --db ${db} \\
            --threads ${task.cpus} \\
            ${report} \\
            ${output_option} \\
            ${unclassified_option} \\
            ${classified_option} \\
            --paired \\
            ${args2} \\
            $input[0] $input[1]
            create_file "\${PREFIX}.krakenuniq.classified.txt"
            create_file "\${PREFIX}.krakenuniq.report.txt"
            create_gzip_file "\${PREFIX}.merged.classified.${sequence_type}.gz"
            create_gzip_file "\${PREFIX}.merged.unclassified.${sequence_type}.gz"

        echo "${compress_reads_command}"

        cat <<-END_VERSIONS > versions.yml
        "${task.process}":
            krakenuniq: \$(echo \$(krakenuniq --version 2>&1) | sed 's/^.*KrakenUniq version //; s/ .*\$//')
        END_VERSIONS
        """
    }
}