//
// Remove host reads via alignment and export off-target reads
//

include { BOWTIE2_ALIGN  } from '../../../modules/nf-core/bowtie2/align/main'
include { SAMTOOLS_INDEX } from '../../../modules/nf-core/samtools/index/main'
include { SAMTOOLS_STATS } from '../../../modules/nf-core/samtools/stats/main'

workflow SHORTREAD_HOSTREMOVAL {
    take:
    reads     // [ [ meta ], [ reads ] ]
    reference // /path/to/fasta
    index     // /path/to/index

    main:
    ch_versions         = channel.empty()
    ch_multiqc_files    = channel.empty()

    ch_bowtie2_index    = index.map { it -> [ [], it] }
    ch_reference        = reference.map { it -> [ [], it] }

    // Map, generate BAM with all reads and unmapped reads in FASTQ for downstream
    BOWTIE2_ALIGN(reads, ch_bowtie2_index, ch_reference, true, true)
    ch_versions = ch_versions.mix(BOWTIE2_ALIGN.out.versions.first())
    ch_multiqc_files = ch_multiqc_files.mix(BOWTIE2_ALIGN.out.log. map { it -> it[1] } )

    // Indexing whole BAM for host removal statistics
    SAMTOOLS_INDEX(BOWTIE2_ALIGN.out.bam)
    ch_versions = ch_versions.mix(SAMTOOLS_INDEX.out.versions.first())

    bam_bai = BOWTIE2_ALIGN.out.bam.join(SAMTOOLS_INDEX.out.bai, remainder: true)

    SAMTOOLS_STATS(bam_bai, ch_reference)
    ch_versions = ch_versions.mix(SAMTOOLS_STATS.out.versions_samtools.first())
    ch_multiqc_files = ch_multiqc_files.mix(SAMTOOLS_STATS.out.stats. map { it -> it[1] } )

    emit:
    stats    = SAMTOOLS_STATS.out.stats
    reads    = BOWTIE2_ALIGN.out.fastq // channel: [ val(meta), [ reads ] ]
    versions = ch_versions // channel: [ versions.yml ]
    mqc      = ch_multiqc_files
}