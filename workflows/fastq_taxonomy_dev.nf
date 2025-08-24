include { QCONTROL                      } from '../modules/local/qcontrol.nf'
include { TRIM                          } from '../modules/local/trim.nf'
include { KRAKEN2                       } from '../modules/local/kraken2.nf'
include { KRAKEN2_CONTIGS               } from '../modules/local/kraken2_contigs.nf'
include { BRACKEN                       } from '../modules/local/bracken.nf'
include { BRACKEN as BRACKEN_CONTIGS    } from '../modules/local/bracken.nf'
include { KRONA                         } from '../modules/local/krona.nf'
include { KRONA as KRONA_CONTIGS        } from '../modules/local/krona.nf'
include { KRONA_METAPHLAN               } from '../modules/local/krona_metaphlan.nf'
include { METASPADES                    } from '../modules/local/metaspades.nf'
include { MEGAHIT                       } from '../modules/local/megahit.nf'
include { ALIGN                         } from '../modules/local/align.nf'
include { METABAT2                      } from '../modules/local/metabat2.nf'
include { CHECKM                        } from '../modules/local/checkm.nf'
include { QUAST_CONTIGS                 } from '../modules/local/quast_contigs.nf'
include { QUAST_BIN                     } from '../modules/local/quast_bin.nf'
include { GTDBTK                        } from '../modules/local/gtdbtk.nf'
include { ANTISMASH                     } from '../modules/local/antismash.nf'
include { METAPHLAN                     } from '../modules/local/metaphlan.nf'
include { METAPHLAN_RESULTS             } from '../modules/local/metaphlan_results'
include { KNEADDATA                     } from '../modules/local/kneaddata.nf'
include { HUMANN                        } from '../modules/local/humann.nf'
include { ALPHA_DIV                     } from '../modules/local/alpha_div.nf'
include { SAMPLE2MAKERS                 } from '../modules/local/sample2markers.nf'
include { STRAINPHLAN                   } from '../modules/local/strainphlan.nf'

workflow FASTQ_TAXONOMY_DEV { 
    take:
    input_fastqs
    kraken2_db
    gtdbtk_db
    metaphlan_db
    metaphlan_db_old
    kneaddata_database
    nucleotide_database
    protein_database
   
    main:
    input_fastqs          |
    QCONTROL & TRIM 
    
    KNEADDATA(TRIM.out.trimmed_reads, kneaddata_database)
    HUMANN(KNEADDATA.out, nucleotide_database, protein_database, metaphlan_db_old)

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
        QUAST_BIN & ANTISMASH

    GTDBTK(METABAT2.out.bins, gtdbtk_db)
    KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    KRAKEN2_CONTIGS(MEGAHIT.out.contigs, kraken2_db)
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db)
    SAMPLE2MAKERS(METAPHLAN.out.sam_bz, metaphlan_db)
    STRAINPHLAN(SAMPLE2MAKERS.out)

    BRACKEN(KRAKEN2.out.report, kraken2_db)
    ALPHA_DIV(BRACKEN.out.txt)
    BRACKEN_CONTIGS(KRAKEN2_CONTIGS.out.report, kraken2_db)
    KRONA(BRACKEN.out.txt)
    KRONA_CONTIGS(BRACKEN_CONTIGS.out.txt)
    KRONA_METAPHLAN(METAPHLAN.out.txt)
    METAPHLAN_RESULTS(METAPHLAN.out.txt)

    emit:
    fastqc              = QCONTROL.out.zip
    kreport             = KRAKEN2.out.report
    kresault            = KRAKEN2.out.result
    kresault_contigs    = KRAKEN2_CONTIGS.out.result
    kreport_contigs     = KRAKEN2_CONTIGS.out.report
    quast               = QUAST_CONTIGS.out.quast_results
    bracken             = BRACKEN.out.txt
    bracken_contigs     = BRACKEN_CONTIGS.out.txt
    quast_bin           = QUAST_BIN.out.quast_results
    metaphlan           = METAPHLAN.out.txt
    gtdbtk              = GTDBTK.out.tsv
}