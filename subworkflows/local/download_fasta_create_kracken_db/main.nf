include { NCBIGENOMEDOWNLOAD                } from '../../../modules/nf-core/ncbigenomedownload/main'
include { MAKE_ACCESSION_FILE               } from '../../../modules/local/make_accession_file/main'
include { FASTA_BUILD_ADD_KRAKEN2_BRACKEN   } from '../../../subworkflows/nf-core/fasta_build_add_kraken2_bracken/main'
include { GUNZIP                            } from '../../../modules/nf-core/gunzip/main'                                                                                             

workflow DOWNLOAD_FASTA_CREATE_KRAKEN_DB {

    take:
    list_of_organisms
    taxonomy_names
    taxonomy_nodes
    accession2taxid
    custom_seqid2taxid
    
    main:
    ch_versions = channel.empty()

    ch_list_of_organisms = list_of_organisms
        .splitCsv(header: ['organism','ncbi_id','refseq_id'], skip: 1)
        .map { it ->  it[0]}
        .map { raw -> [ raw.organism, raw.refseq_id ] }

    //
    // MODULE: Run MAKE_ACCESSION_FILE to create accession file for NCBIGENOMEDOWNLOAD
    //
    MAKE_ACCESSION_FILE (
        ch_list_of_organisms
    )
    ch_versions = ch_versions.mix(MAKE_ACCESSION_FILE.out.versions)
    ch_organism_file = MAKE_ACCESSION_FILE.out.accession
    //
    // MODULE: Run NCBIGENOMEDOWNLOAD to download FASTA files from NCBI
    //
    NCBIGENOMEDOWNLOAD (
        ch_organism_file.map { it -> [id: it[0]] },
        ch_organism_file.map { it -> it[1] },
        [],
        'all'
    )
    ch_versions = ch_versions.mix(NCBIGENOMEDOWNLOAD.out.versions)
    ch_fasta    = NCBIGENOMEDOWNLOAD.out.fna
    //
    // MODULE: Run GUNZIP to decompress downloaded FASTA files
    //
    GUNZIP (
        ch_fasta
    )
    ch_fasta = GUNZIP.out.gunzip
        .map { it -> it[1] }
        .collect()
        .map { it -> [[id: 'fake_id'], it] }
    ch_versions = ch_versions.mix(GUNZIP.out.versions)
    //
    // MODULE: Run FASTA_BUILD_ADD_KRAKEN2_BRACKEN to build Kraken2/Bracken database
    //
    FASTA_BUILD_ADD_KRAKEN2_BRACKEN (
        ch_fasta,
        taxonomy_names,
        taxonomy_nodes,
        accession2taxid,
        false,
        custom_seqid2taxid,
        true,
    )
    ch_versions = ch_versions.mix(FASTA_BUILD_ADD_KRAKEN2_BRACKEN.out.versions)

}