process TRIM {
    container 'nanozoo/fastp:0.23.1--9f2e255'
    errorStrategy 'ignore'

    input:
    tuple val(is_single_end), val(sid), path(reads)

    output:
    tuple val(is_single_end), val(sid), path("*trimmed.fastq.gz"), emit: trimmed_reads
    path '*.html', emit: html, optional: true
    path '*.json', emit: json, optional: true

    script:
    if (is_single_end) {
        """
        fastp \
            --thread ${task.cpus} \
            --in1 ${reads} \
            --out1 ${sid}_trimmed.fastq.gz \
            --html ${sid}.fastp_stats.html \
            --json ${sid}.fastp_stats.json 
        """
    } else {
        """
        fastp \
            --thread ${task.cpus} \
            --in1 ${reads[0]} \
            --in2 ${reads[1]} \
            --out1 ${sid}_R1_trimmed.fastq.gz \
            --out2 ${sid}_R2_trimmed.fastq.gz \
            --html ${sid}.fastp_stats.html \
            --json ${sid}.fastp_stats.json 
        """
    }

    stub:
    if (is_single_end) {
        """
        touch ${sid}.fastp_stats.html
        touch ${sid}.fastp_stats.json
        touch ${sid}_trimmed.fastq.gz
        """
    } else {
        """
        touch ${sid}.fastp_stats.html
        touch ${sid}.fastp_stats.json
        touch ${sid}_R1_trimmed.fastq.gz
        touch ${sid}_R2_trimmed.fastq.gz
        """
    }
}