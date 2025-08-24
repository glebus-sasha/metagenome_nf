include { COMPARE_ABUDANCE                                  } from '../../modules/local/compare_abundance.nf'
include { COMPARE_ABUDANCE as COMPARE_ABUDANCE_CONTIGS      } from '../../modules/local/compare_abundance.nf'
include { CONVERT_TRUTH                                     } from '../../modules/local/convert_truth.nf'
include { CONVERT_METAPHLAN                                 } from '../../modules/local/convert_metaphlan.nf'
include { CONVERT_METAPHLAN as CONVERT_METAPHLAN_CONTIGS    } from '../../modules/local/convert_metaphlan.nf'
include { CONVERT_KRAKEN                                    } from '../../modules/local/convert_kraken.nf'
include { CONVERT_KRAKEN as CONVERT_KRAKEN_CONTIGS          } from '../../modules/local/convert_kraken.nf'
include { CONVERT_GTDBTK                                    } from '../../modules/local/convert_gtdbtk.nf'
include { CONVERT_BRACKEN                                   } from '../../modules/local/convert_bracken.nf'
include { CONVERT_BRACKEN as CONVERT_BRACKEN_CONTIGS        } from '../../modules/local/convert_bracken.nf'
include { COMPARE_ALL_VS_TRUTH                              } from '../../modules/local/compare_all_vs_truth.nf'

workflow compare_taxonomy {
    take:
    truth_tax
    ar122_file
    bac120_file
    kresault
    kresault_contigs
    bracken
    bracken_contigs
    metaphlan
    gtdbtk
    
    main:
    CONVERT_TRUTH(truth_tax)
    CONVERT_KRAKEN(kresault, '')
    CONVERT_KRAKEN_CONTIGS(kresault_contigs, 'contigs-')
    CONVERT_BRACKEN(bracken, '')
    CONVERT_BRACKEN_CONTIGS(bracken_contigs, 'contigs-')
    CONVERT_METAPHLAN(metaphlan)
    CONVERT_GTDBTK(gtdbtk, ar122_file, bac120_file)
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