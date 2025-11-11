#!/usr/bin/env nextflow
/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    nf-core/metagenome
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    Github : https://github.com/glebus-sasha/metagenome_nf
----------------------------------------------------------------------------------------
*/

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    IMPORT FUNCTIONS / MODULES / SUBWORKFLOWS / WORKFLOWS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

include { FASTQC                                                  } from './modules/nf-core/fastqc'
include { FASTP                                                   } from './modules/nf-core/fastp'
include { CAT_FASTQ                                               } from './modules/nf-core/cat/fastq'
include { METAPHLAN_METAPHLAN                                     } from './modules/nf-core/metaphlan/metaphlan'
include { KRAKEN2_KRAKEN2                                         } from './modules/nf-core/kraken2/kraken2'
include { BRACKEN_BRACKEN                                         } from './modules/nf-core/bracken/bracken'
include { KRAKENUNIQ                                              } from './modules/local/krakenuniq'
include { TAXPASTA_STANDARDISE as TAXPASTA_STANDARDISE_METAPHLAN  } from './modules/nf-core/taxpasta/standardise'
include { TAXPASTA_STANDARDISE as TAXPASTA_STANDARDISE_BRACKEN    } from './modules/nf-core/taxpasta/standardise'
include { TAXPASTA_STANDARDISE as TAXPASTA_STANDARDISE_KRAKENUNIQ } from './modules/nf-core/taxpasta/standardise'
include { softwareVersionsToYAML                                  } from './subworkflows/nf-core/utils_nfcore_pipeline'
include { MULTIQC                                                 } from './modules/nf-core/multiqc'

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    RUN MAIN WORKFLOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

workflow {
    input_fastqs = Channel.fromPath("${params.reads}/*.[fq,fastq]*")
        .map { file ->
            def sampleName = file.simpleName.replaceFirst(/_[rR][12]$/, '')
            [sampleName, file]
        }
        .groupTuple()
        .map { sampleName, files ->
            def isSingleEnd = files.size() == 1
                        [
                [id: sampleName, single_end: isSingleEnd],
                files.sort()
            ]
        }

    metaphlan_db        = Channel.fromPath("${params.metaphlan_db}").collect()
    kraken2_db          = Channel.fromPath("${params.kraken2_db}").collect()
    krakenuniq_db       = Channel.fromPath("${params.krakenuniq_db}").collect()
    ncbi_taxdump        = Channel.fromPath("${params.ncbi_taxdump}").collect()

    ch_versions = Channel.empty()
    ch_multiqc_files = Channel.empty()
    //
    // MODULE: Run FastQC
    //
    FASTQC (
        input_fastqs
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{it[1]})
    ch_versions = ch_versions.mix(FASTQC.out.versions.first())
    //
    // MODULE: Run FastP
    //
    FASTP (
        input_fastqs,
        [],
        [],
        false,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect{it[1]})
    ch_versions = ch_versions.mix(FASTP.out.versions.first())
    //
    // MODULE: Run cat fastq
    //
    ch_cat_fastq = FASTP.out.reads
        // Обновляем ID по правилу 7 частей с конца
        .map { tuple ->
            def (meta, files) = tuple
            def oldId = meta.id
            
            // Разбиваем старый ID по _
            def parts = oldId.split('_')
            
            // Берем последние 7 частей (или меньше, если частей меньше 7)
            def newId = parts.length >= 7 ? 
                parts[-7..-1].join('_') : 
                parts.join('_')
            
            // Создаем новый meta с обновленным ID
            def newMeta = meta.clone()
            newMeta.id = newId
            
            // Возвращаем tuple с новым meta и файлами
            [newMeta, files]
        }
        
        // Группируем по новому ID (для мержинга)
        .groupTuple(by: [0])
        
        // Сортируем файлы внутри каждой группы для правильного порядка
        .map { tuple ->
            def (meta, filesList) = tuple
            
            // filesList - это список списков файлов, flatten делаем его плоским
            def allFiles = filesList.flatten()
            
            // Сортируем файлы для правильного порядка (R1, R2, R1, R2, ...)
            def sortedFiles = allFiles.sort()
            
            [meta, sortedFiles]
        }
    CAT_FASTQ (
        ch_cat_fastq
    )
    ch_versions = ch_versions.mix(CAT_FASTQ.out.versions.first())
    //
    // MODULE: Run MetaPlAn
    //
    METAPHLAN_METAPHLAN (
        CAT_FASTQ.out.reads,
        metaphlan_db,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(METAPHLAN_METAPHLAN.out.profile.collect{it[1]})
    ch_versions = ch_versions.mix(METAPHLAN_METAPHLAN.out.versions.first())
    //
    // MODULE: Run Kraken 2
    //
    KRAKEN2_KRAKEN2 (
        CAT_FASTQ.out.reads,
        kraken2_db,
        false,
        false
    )
    ch_multiqc_files = ch_multiqc_files.mix(KRAKEN2_KRAKEN2.out.report.collect{it[1]})
    ch_versions = ch_versions.mix(KRAKEN2_KRAKEN2.out.versions.first())
    //
    // MODULE: Run Bracken
    //
    BRACKEN_BRACKEN (
        KRAKEN2_KRAKEN2.out.report,
        kraken2_db
    )
    ch_multiqc_files = ch_multiqc_files.mix(BRACKEN_BRACKEN.out.reports.collect{it[1]})
    ch_versions = ch_versions.mix(BRACKEN_BRACKEN.out.versions.first())
/*
    //
    // MODULE: Run KrakenUniq
    //
    KRAKENUNIQ (
        CAT_FASTQ.out.reads,
        'fastq',
        krakenuniq_db,
        false,
        false,
        false
    )
    ch_versions = ch_versions.mix(KRAKENUNIQ.out.versions.first())
*/
    //
    // MODULE: Run TAXPASTA_STANDARDISE_METAPHLAN
    //
    TAXPASTA_STANDARDISE_METAPHLAN (
        METAPHLAN_METAPHLAN.out.profile,
        'metaphlan',
        'tsv',
        ncbi_taxdump
    )
    ch_versions = ch_versions.mix(TAXPASTA_STANDARDISE_METAPHLAN.out.versions.first())
    //
    // MODULE: Run TAXPASTA_STANDARDISE_METAPHLAN
    //
    TAXPASTA_STANDARDISE_BRACKEN (
        BRACKEN_BRACKEN.out.reports,
        'bracken',
        'tsv',
        ncbi_taxdump
    )
    //
    // Collate and save software versions
    //
    softwareVersionsToYAML(ch_versions)
        .collectFile(
            storeDir: "${params.outdir}/pipeline_info",
            name:  'metagenome_software_'  + 'mqc_'  + 'versions.yml',
            sort: true,
            newLine: true
        ).set { ch_collated_versions }
    //
    // MODULE: MultiQC
    //
    ch_multiqc_files = ch_multiqc_files.mix(ch_collated_versions)
    MULTIQC (
        ch_multiqc_files.collect(),
        [],
        [],
        [],
        [],
        []
    )
}

/*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    THE END
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/