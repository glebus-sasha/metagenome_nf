process UNIFY_RESULTS {
    container 'glebusasha/compare_abundance:latest'

    input:
    tuple val(sid), path(input_file)
    
    output:
    tuple val(sid), path("${sid}_final_profile.csv")
    script:
    """
    # Определяем по первой строке - если есть табы, то это Bracken
    first_line=\$(head -1 "${input_file}")
    if echo "\$first_line" | grep -q \$'\\t'; then
        # Bracken - заменяем все табы на точку с запятой
        awk 'BEGIN {FS="\\t"; OFS=";"} {print \$1, \$2, \$3, \$4, \$5, \$6, \$7}' "${input_file}" > ${sid}_final_profile.csv
    else
        # MetaPhlAn - уже CSV, просто копируем
        cp "${input_file}" ${sid}_final_profile.csv
    fi
    """
}