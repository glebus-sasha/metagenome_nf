include { QCONTROL                      } from '../processes/qcontrol.nf'
include { TRIM                          } from '../processes/trim.nf'
include { KRAKEN2                       } from '../processes/kraken2.nf'
include { KRAKEN2_CONTIGS               } from '../processes/kraken2_contigs.nf'
include { BRACKEN                       } from '../processes/bracken.nf'
include { BRACKEN as BRACKEN_CONTIGS    } from '../processes/bracken.nf'
include { KRONA                         } from '../processes/krona.nf'
include { KRONA as KRONA_CONTIGS        } from '../processes/krona.nf'
include { KRONA_METAPHLAN               } from '../processes/krona_metaphlan.nf'
include { METASPADES                    } from '../processes/metaspades.nf'
include { MEGAHIT                       } from '../processes/megahit.nf'
include { ALIGN                         } from '../processes/align.nf'
include { METABAT2                      } from '../processes/metabat2.nf'
include { CHECKM                        } from '../processes/checkm.nf'
include { QUAST_CONTIGS                 } from '../processes/quast_contigs.nf'
include { QUAST_BIN                     } from '../processes/quast_bin.nf'
include { GTDBTK                        } from '../processes/gtdbtk.nf'
include { ANTISMASH                     } from '../processes/antismash.nf'
include { METAPHLAN                     } from '../processes/metaphlan.nf'
include { METAPHLAN_RESULTS             } from '../processes/metaphlan_results.nf'
include { KNEADDATA                     } from '../processes/kneaddata.nf'
include { HUMANN                        } from '../processes/humann.nf'
include { ALPHA_DIV                     } from '../processes/alpha_div.nf'
include { SAMPLE2MAKERS                 } from '../processes/sample2markers.nf'
include { STRAINPHLAN                   } from '../processes/strainphlan.nf'


workflow FASTQ_TAXONOMY { 
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
    
    //KNEADDATA(TRIM.out.trimmed_reads, kneaddata_database)
    //HUMANN(KNEADDATA.out, nucleotide_database, protein_database, metaphlan_db_old)

    /*MEGAHIT(TRIM.out.trimmed_reads)
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

    GTDBTK(METABAT2.out.bins, gtdbtk_db)*/
    /*KRAKEN2(TRIM.out.trimmed_reads, kraken2_db)
    KRAKEN2_CONTIGS(MEGAHIT.out.contigs, kraken2_db)*/
    METAPHLAN(TRIM.out.trimmed_reads, metaphlan_db)
    /*SAMPLE2MAKERS(METAPHLAN.out.sam_bz, metaphlan_db)
    //STRAINPHLAN(SAMPLE2MAKERS.out)*/

    //BRACKEN(KRAKEN2.out.report, kraken2_db)
    /*ALPHA_DIV(BRACKEN.out.txt)
    BRACKEN_CONTIGS(KRAKEN2_CONTIGS.out.report, kraken2_db)
    //KRONA(BRACKEN.out.txt)
    //KRONA_CONTIGS(BRACKEN_CONTIGS.out.txt)
    KRONA_METAPHLAN(METAPHLAN.out.txt)*/
    METAPHLAN_RESULTS(METAPHLAN.out.txt)

    emit:
    fastqc              = QCONTROL.out.zip
/*    kreport             = KRAKEN2.out.report
    kresault            = KRAKEN2.out.result
    kresault_contigs    = KRAKEN2_CONTIGS.out.result
    kreport_contigs     = KRAKEN2_CONTIGS.out.report
    quast               = QUAST_CONTIGS.out.quast_results
    bracken             = BRACKEN.out.txt
    bracken_contigs     = BRACKEN_CONTIGS.out.txt
    quast_bin           = QUAST_BIN.out.quast_results
    metaphlan           = METAPHLAN.out.txt
    gtdbtk              = GTDBTK.out.tsv*/
}