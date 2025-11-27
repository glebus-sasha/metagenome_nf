                                                                                           
include { FASTQC                            } from '../../../modules/nf-core/fastqc'
include { FASTP                             } from '../../../modules/nf-core/fastp'
include { CAT_FASTQ                         } from '../../../modules/nf-core/cat/fastq'
workflow FASTQ_PREPARE {

    take:
    input_fastqs
    
    main:
    ch_versions         = channel.empty()
    ch_multiqc_files    = channel.empty()

    //
    // MODULE: Run FastQC
    //
    FASTQC (
        input_fastqs
    )
    ch_multiqc_files = ch_multiqc_files.mix(FASTQC.out.zip.collect{ it -> it[1] })
    ch_versions      = ch_versions.mix(FASTQC.out.versions.first())
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
    ch_multiqc_files = ch_multiqc_files.mix(FASTP.out.json.collect{ it -> it[1]} )
    ch_versions      = ch_versions.mix(FASTP.out.versions.first())
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
    ch_reads = CAT_FASTQ.out.reads

    emit:
    reads = ch_reads
    versions = ch_versions
    multiqc_files = ch_multiqc_files

}