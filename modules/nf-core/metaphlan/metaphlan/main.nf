process METAPHLAN_METAPHLAN {
    tag "${meta.id}"
    label 'process_high'

    conda "${moduleDir}/environment.yml"
    container "${workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container
        ? 'https://depot.galaxyproject.org/singularity/metaphlan:4.2.2--pyhdfd78af_0'
        : 'biocontainers/metaphlan:4.2.2--pyhdfd78af_0'}"

    input:
    tuple val(meta), path(input)
    path metaphlan_db_latest
    val save_samfile

    output:
    tuple val(meta), path("*_profile.txt"), emit: profile
    tuple val(meta), path('*.bowtie2out.txt'), optional: true, emit: bt2out
    tuple val(meta), path("*.sam"), optional: true, emit: sam
    tuple val(meta), path("*_mp3_viruses.csv"), optional: true, emit: mp3_viruses
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def input_type = "${input}" =~ /.*\.(fastq|fq)/ ? "--input_type fastq" : "${input}" =~ /.*\.(fasta|fna|fa)/ ? "--input_type fasta" : "${input}".endsWith(".bowtie2out.txt") ? "--input_type bowtie2out" : "--input_type sam"
    def input_data = ("${input_type}".contains("fastq")) && !meta.single_end ? "${input[0]},${input[1]}" : "${input}"
    def bowtie2_out = "${input_type}" == "--input_type mapout" || "${input_type}" == "--input_type sam" ? '' : "--mapout ${prefix}.bowtie2out.txt"
    def samfile_out = save_samfile ? "-s ${prefix}.sam" : ''
    """
    BT2_DB=`find -L "${metaphlan_db_latest}" -name "*rev.1.bt2*" -exec dirname {} \\;`
    BT2_DB_INDEX=`find -L ${metaphlan_db_latest} -name "*.rev.1.bt2*" | sed 's/\\.rev.1.bt2.*\$//' | sed 's/.*\\///'`

    metaphlan \\
        --nproc ${task.cpus} \\
        ${input_type} \\
        ${input_data} \\
        ${args} \\
        ${bowtie2_out} \\
        ${samfile_out} \\
        --profile_vsc \\
        --db_dir \$BT2_DB \\
        --index \$BT2_DB_INDEX \\
        --output_file ${prefix}_profile.txt
    
    mv mp3_viruses.csv ${prefix}_mp3_viruses.csv || true

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """

    stub:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    """
    echo "${args}"
    touch ${prefix}_profile.txt

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        metaphlan: \$(metaphlan --version 2>&1 | awk '{print \$3}')
    END_VERSIONS
    """
}
