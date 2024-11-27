make file path_config.py inside metagenome_nf folder
```
mkdir path_config.py
```

contain path_config.py
```
READS_FOLDER    = "<path/to/tmp/folder/reads>"
OUTPUT_FOLDER   = "<path/to/output>"
nextflow_path   = "<path/to/metagenome_nf>"
kraken2_db      = "<path/to/kraken2_db>"
GTDB_db         = "<path/to/GTDB_db/release>"

nextflow_command = ["nextflow", "run",
 "./main.nf", "-profile", "singularity",
    "--reads", READS_FOLDER,
    "--outdir", OUTPUT_FOLDER,
    "--kraken2_db", kraken2_db,
    "--gtdbtk_db", GTDB_db]
```

create /etc/systemd/system/metagenome_web.service
```
sudo nano /etc/systemd/system/metagenome_web.service
```
metagenome_web.service contains
```
[Unit]
Description=Metagenome Analysis Service
After=network.target

[Service]
User=<username>
Group=<groupname>
WorkingDirectory=<path/to/metagenome_nf>
Environment="PATH=</home/username/.sdkman/candidates/java/current/bin:/home/username/.local/bin:/usr/local/bin:/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin:/home/username/.local/bin/flask:/usr/local/bin/nextflow:/media/username/DATA/.reads_tmp:/media/username/DATA/output:/home/username/metagenome_nf>"
Environment="NXF_SINGULARITY_CACHEDIR=</home/username/.singularity>"
ExecStart=/usr/bin/python3 </home/username/metagenome_nf/server.py>
Restart=always
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
```
enable service
```
sudo systemctl enable metagenome_web.service
```