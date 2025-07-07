#!/usr/bin/env nextflow
include { QCONTROL                      } from './processes/qcontrol.nf'
include { TRIM                          } from './processes/trim.nf'
include { KRAKEN2                       } from './processes/kraken2.nf'
include { KRAKEN2_CONTIGS               } from './processes/kraken2_contigs.nf'
include { BRACKEN                       } from './processes/bracken.nf'
include { BRACKEN as BRACKEN_CONTIGS    } from './processes/bracken.nf'
include { KRONA                         } from './processes/krona.nf'
include { KRONA as KRONA_CONTIGS        } from './processes/krona.nf'
include { KRONA_METAPHLAN               } from './processes/krona_metaphlan.nf'
include { METASPADES                    } from './processes/metaspades.nf'
include { MEGAHIT                       } from './processes/megahit.nf'
include { ALIGN                         } from './processes/align.nf'
include { METABAT2                      } from './processes/metabat2.nf'
include { CHECKM                        } from './processes/checkm.nf'
include { QUAST_CONTIGS                 } from './processes/quast_contigs.nf'
include { QUAST_BIN                     } from './processes/quast_bin.nf'
include { GTDBTK                        } from './processes/gtdbtk.nf'
include { METAPHLAN                     } from './processes/metaphlan.nf'
include { REPORT                        } from './processes/report.nf'
include { COMPARE_ABUDANCE              } from './processes/compare_abundance.nf'
include { COMPARE_ABUDANCE as COMPARE_ABUDANCE_CONTIGS   } from './processes/compare_abundance.nf'
include { CONVERT_TRUTH                 } from './processes/convert_truth.nf'
include { CONVERT_METAPHLAN             } from './processes/convert_metaphlan.nf'
include { CONVERT_METAPHLAN as CONVERT_METAPHLAN_CONTIGS } from './processes/convert_metaphlan.nf'
include { CONVERT_KRAKEN                } from './processes/convert_kraken.nf'
include { CONVERT_KRAKEN as CONVERT_KRAKEN_CONTIGS       } from './processes/convert_kraken.nf'
include { CONVERT_GTDBTK                } from './processes/convert_gtdbtk.nf'
include { CONVERT_BRACKEN               } from './processes/convert_bracken.nf'
include { CONVERT_BRACKEN as CONVERT_BRACKEN_CONTIGS     } from './processes/convert_bracken.nf'
include { COMPARE_ALL_VS_TRUTH          } from './processes/compare_all_vs_truth.nf'





// Logging pipeline information
log.info """\
\033[0;36m  ==========================================  \033[0m
\033[0;34m              M E T A G E N O M E             \033[0m
\033[0;36m  ==========================================  \033[0m

    reads:      ${params.reads}
    outdir:     ${params.outdir}
    workDir:    ${workflow.workDir}
    """
    .stripIndent(true)

def result_dir      = new File("${params.outdir}")
input_fastqs        = Channel.fromFilePairs(["${params.reads}/*[rR]{1,2}*.*{fastq,fq}*", "${params.reads}/*_{1,2}.{fastq,fq}*"])
kraken2_db          = params.kraken2_db ? Channel.fromPath("${params.kraken2_db}").collect(): null
gtdbtk_db           = params.gtdbtk_db ? Channel.fromPath("${params.gtdbtk_db}").collect(): null
metaphlan_db        = params.metaphlan_db ? Channel.fromPath("${params.metaphlan_db}").collect(): null
truth_tax           = Channel.fromPath("${params.truth_tax}/*.*tsv*").map { tuple(it.baseName, it) }
ar122_file          = Channel.fromPath("${params.ar122_file}").collect()
bac120_file         = Channel.fromPath("${params.bac120_file}").collect()

workflow { 
    input_fastqs          |
    QCONTROL & TRIM

    MEGAHIT(TRIM.out.trimmed_reads) 
    QUAST_CONTIGS(MEGAHIT.out.contigs)

    TRIM.out.trimmed_reads.join(MEGAHIT.out.contigs) |
    ALIGN
    MEGAHIT.out.contigs.join(ALIGN.out.bam) |
    METABAT2                                |
    CHECKM

    METABAT2.out.bins |
        map { sid, bins_dir ->
            file(bins_dir).listFiles().findAll { it.name.endsWith('.fa') }.collect { bin_file ->
                [sid, bin_file]
            }
        }             |
        flatMap       |
        QUAST_BIN

    GTDBTK(METABAT2.out.bins, gtdbtk_db)
    KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    KRAKEN2_CONTIGS(MEGAHIT.out.contigs, kraken2_db)
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db)
    BRACKEN(KRAKEN2.out.report, kraken2_db)
    BRACKEN_CONTIGS(KRAKEN2_CONTIGS.out.report, kraken2_db)
    //KRONA(BRACKEN.out.txt)
    //KRONA_CONTIGS(BRACKEN_CONTIGS.out.txt)
    KRONA_METAPHLAN(METAPHLAN.out.txt)
    TRIM.out.json                                   |
        mix(QCONTROL.out.zip)                       |
        mix(KRAKEN2.out.report.map{it[1]})          |
        mix(KRAKEN2_CONTIGS.out.report.map{it[1]})  |
        mix(QUAST_CONTIGS.out.quast_results)        |   
        mix(QUAST_BIN.out.quast_results)            |
        mix(METAPHLAN.out.txt.map{it[1]})           |
        //mix(METAPHLAN_CONTIGS.out.txt.map{it[1]})   |
        mix(GTDBTK.out.tsv.map{it[1]})              |
        collect                                     |
        REPORT
    //COMPARE_ABUDANCE(truth_tax.join(KRAKEN2.out.result))
    //COMPARE_ABUDANCE_CONTIGS(truth_tax.join(KRAKEN2_CONTIGS.out.result))
    CONVERT_TRUTH(truth_tax)
    CONVERT_KRAKEN(KRAKEN2.out.result, '')
    CONVERT_KRAKEN_CONTIGS(KRAKEN2_CONTIGS.out.result, 'contigs-')
    CONVERT_BRACKEN(BRACKEN.out.txt, '')
    CONVERT_BRACKEN_CONTIGS(BRACKEN_CONTIGS.out.txt, 'contigs-')
    CONVERT_METAPHLAN(METAPHLAN.out.txt)
    CONVERT_GTDBTK(GTDBTK.out.tsv, ar122_file, bac120_file)
    COMPARE_ALL_VS_TRUTH(
        CONVERT_TRUTH.out
        .join(CONVERT_KRAKEN.out)
        .join(CONVERT_KRAKEN_CONTIGS.out)
        .join(CONVERT_BRACKEN.out)
        .join(CONVERT_BRACKEN_CONTIGS.out)
        .join(CONVERT_METAPHLAN.out)
        .join(CONVERT_GTDBTK.out)
        .map {tuple(it[0], it[1..-1])},
        'truth'
        )

}