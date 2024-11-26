READS_FOLDER = "/home/aglebus/Documents/metagenome_nf/reads"
OUTPUT_FOLDER = "/home/aglebus/Documents/metagenome_nf/output"
nextflow_path = "/home/aglebus/Documents/metagenome_nf"
kraken2_db       = "/storage/aglebus/meta/kraken2_db"
gtdbtk_db        = "/storage/aglebus/meta/GTDB_db/release220"

nextflow_command = ["nextflow", "run", "./main.nf", "-profile", "singularity", "--reads", READS_FOLDER, "--outdir", OUTPUT_FOLDER, "--kraken2_db", kraken2_db, "--gtdbtk_db", GTDB_db]