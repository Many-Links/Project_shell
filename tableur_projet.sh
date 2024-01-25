#Guemmar_Abderrahmane
#L3-info-TD-2-Groupe-c



#!/bin/bash
input="input.txt"
output="output.txt"
sep_col_in=$':'
sep_row_in=$'\n'
sep_col_out=$'\t'
sep_row_out=$':'
    inverse=false

        while [ "$#" -gt 0 ]; do
        case "$1" in
            -in)
            shift
            input="$1"
            ;;
            -out)
            shift
            output="$1"
            ;;
            -scin)
            shift
            sep_col_in="$1"
            ;;
            -slin)
            shift
            sep_row_in="$1"
            ;;
            -scout)
            shift
            sep_col_out="$1"
            ;;
            -slout)
            shift
            sep_row_out="$1"
            ;;
            -inverse)
            inverse=true
            ;;
            *)
            echo "Option invalide: $1" >&2
            exit 1
            ;;
        esac
        shift
        done

        
        
      

        nb_cl() {
                    local c=$1
                    local nb_col=$(echo "$c" | cut -d 'c' -f2)
                    echo "$nb_col"
                }

        nb_lig() {
                    local l=$1
                    local nb_lig=$(echo "$l" | grep -o 'l[0-9]\+' | cut -c 2-)  
                    echo "$nb_lig"
                }


        [cel]() {
        
        
            local var=$1
            local colonne=$(nb_cl "$var")
            local ligne=$(nb_lig "$var")

            local line=$(sed -n "${ligne}p" "$input")

            # Utiliser le séparateur de colonnes défini
            IFS="$sep_col_in" read -ra cells <<< "$line"
            cellule="${cells[colonne-1]}"

            echo "$cellule"
        }
        # Fonction pour l'opération de somme
        +() {
            local val1=$1
            local val2=$2

            local result=$(( $([cel] "$val1") + $([cel] "$val2") ))
            echo "$result"
        }

        # Fonction pour l'opération de différence
        -() {
            local val1=$1
            local val2=$2

            local result=$(( $([cel] "$val1") - $([cel] "$val2") ))
            echo "$result"
        }

        # Fonction pour l'opération de produit
        *() {
            local val1=$1
            local val2=$2

            local result=$(( $([cel] "$val1") * $([cel] "$val2") ))
            echo "$result"
        }

        # Fonction pour l'opération de quotient
        /() {
            local val1=$1
            local val2=$2

            local result=$(( $([cel] "$val1") / $([cel] "$val2") ))
            echo "$result"
        }

        # Fonction pour l'opération  à la puissance
        ˆ() {
            local val1=$1
            local val2=$2

            local result=$(( $([cel] "$val1") ** $([cel] "$val2") ))
            echo "$result"
        }
    somme() {
    local cel1=$1
    local cel2=$2

    local ligne1=$(nb_lig "$cel1")
    local col1=$(nb_cl "$cel1")

    local ligne2=$(nb_lig "$cel2")
    local col2=$(nb_cl "$cel2")

    local somme=0

    for ((i = ligne1; i <= ligne2; i++)); do
        for ((j = col1; j <= col2; j++)); do
            local cel="l${i}c${j}"
            local valeur=$([cel] "$cel")
            somme=$((somme + valeur))
        done
    done

    echo "$somme"
}
        nb_cells() {
            local start_row=$(nb_lig "$1")
            local start_col=$(nb_cl "$1")
            local end_row=$(nb_lig "$2")
            local end_col=$(nb_cl "$2")
            local count=0

            for row in $(seq "$start_row" "$end_row"); do
                for col in $(seq "$start_col" "$end_col"); do
                    local cell_value=$([cel] "l${row}c${col}")
                    if [ -n "$cell_value" ]; then
                        count=$((count + 1))
                    fi
                done
            done

            echo "$count"
        }

        moyenne() {
            local s=$1
            local e=$2
            local total_cells=$(nb_cells "$s" "$e")
            local total_sum=0

            local start_row=$(nb_lig "$s")
            local start_col=$(nb_cl "$s")
            local end_row=$(nb_lig "$e")
            local end_col=$(nb_cl "$e")

            if [ $(($start_row - $end_row)) -eq 0 ]; then
                # Les cellules sont sur la même ligne
                for col in $(seq "$start_col" "$end_col"); do
                    local cell_value=$([cel] "l${start_row}c${col}")
                    if [ -n "$cell_value" ]; then
                        total_sum=$((total_sum + cell_value))
                    fi
                done
            else
                # Les cellules couvrent plusieurs lignes
                for row in $(seq "$start_row" "$end_row"); do
                    for col in $(seq "$start_col" "$end_col"); do
                        local cell_value=$([cel] "l${row}c${col}")
                        if [ -n "$cell_value" ]; then
                            total_sum=$((total_sum + cell_value))
                        fi
                    done
                done
            fi

            if [ "$total_cells" -gt 0 ]; then
                local final=$(echo "scale=2; $total_sum / $total_cells" | bc)
                echo $final
            else
                echo "Erreur: Aucune cellule avec une valeur valide dans la plage spécifiée."
            fi
        }


        ln(){
            echo "ln($v1)" |bc -l
        }
        e(){
            local v1=$1
        echo "e($v1)" |bc -l 
        }

        sqrt() {
            local operand=$1
            echo "sqrt($operand)" | bc -l
        }


        variance() {
            local start_cell=$1
            local end_cell=$2
            local total_cells=$(nb_cells "$start_cell" "$end_cell")

            if [ "$total_cells" -gt 1 ]; then
                local mean=$(moyenne "$start_cell" "$end_cell")
                local squared_diff_sum=0

                local start_row=$(nb_lig "$start_cell")
                local start_col=$(nb_cl "$start_cell")
                local end_row=$(nb_lig "$end_cell")
                local end_col=$(nb_cl "$end_cell")

                for row in $(seq "$start_row" "$end_row"); do
                    for col in $(seq "$start_col" "$end_col"); do
                        local cell_value=$([cel] "l${row}c${col}")
                        if [ -n "$cell_value" ]; then
                            local diff=$(echo "scale=2; $cell_value - $mean" | bc)
                            squared_diff_sum=$(echo "scale=2; $squared_diff_sum + $diff * $diff" | bc)
                        fi
                    done
                done

                local variance=$(echo "scale=2; $squared_diff_sum / ($total_cells)" | bc)
                echo $variance
            else
                echo "Erreur: Au moins deux cellules avec des valeurs valides sont nécessaires pour calculer la variance."
            fi
        }


        ecarttype() {
            local start_cell=$1
            local end_cell=$2
            local total_cells=$(nb_cells "$start_cell" "$end_cell")

            if [ "$total_cells" -gt 1 ]; then
                local variance=$(variance "$start_cell" "$end_cell")
                local ecart_type=$(echo "scale=2; sqrt($variance)" | bc)
                echo $ecart_type
            else
                echo "Erreur: Au moins deux cellules avec des valeurs valides sont nécessaires pour calculer l'écart type."
            fi
        }

        min() {
            local start_cell=$1
            local end_cell=$2

            local start_row=$(nb_lig "$start_cell")
            local start_col=$(nb_cl "$start_cell")
            local end_row=$(nb_lig "$end_cell")
            local end_col=$(nb_cl "$end_cell")

            # Initialiser le minimum avec la valeur de la première cellule
            local min=$([cel] "$start_cell")

            for row in $(seq "$start_row" "$end_row"); do
                for col in $(seq "$start_col" "$end_col"); do
                    local cell_value=$([cel] "l${row}c${col}")
                    if [ -n "$cell_value" ]; then
                        if [ "$cell_value" -lt "$min" ]; then
                            min=$cell_value
                        fi
                    fi
                done
            done

            echo "$min"
        }

        max() {
            local start_cell=$1
            local end_cell=$2

            local total_cells=$(nb_cells "$start_cell" "$end_cell")

            if [ "$total_cells" -gt 0 ]; then
                local start_row=$(nb_lig "$start_cell")
                local start_col=$(nb_cl "$start_cell")
                local end_row=$(nb_lig "$end_cell")
                local end_col=$(nb_cl "$end_cell")

                # Initialiser le maximum avec la valeur de la première cellule non vide
                local max=$([cel] "$start_cell")

                for row in $(seq "$start_row" "$end_row"); do
                    for col in $(seq "$start_col" "$end_col"); do
                        local cell_value=$([cel] "l${row}c${col}")
                        if [ -n "$cell_value" ]; then
                            if [ "$cell_value" -gt "$max" ]; then
                                max=$cell_value
                            fi
                        fi
                    done
                done

                echo "$max"
            else
                echo "Erreur: Aucune cellule avec une valeur valide dans la plage spécifiée."
            fi
        }

        eval_expr() {
    local expr=$1
    local result

    # Vérifier si l'expression commence par "shell"
    if [[ "$expr" =~ ^'shell' ]]; then
        # Évaluer l'expression shell
        result=$(shell "${expr:5}")
    else
        # La cellule ne contient aucune expression à évaluer
        result="$expr"
    fi

    echo "$result"
}
        concat() {
            local val1=$1
            local val2=$2

            local result="$val1$val2"
            echo "$result"
        }
        length() {
            local val=$1
            local len=$(echo -n "$val" | wc -c)
            echo "$len"
        }
        substitute() {
            local val1=$1
            local val2=$2
            local val3=$3

            local result=$(echo "$val1" | sed "s/$val2/$val3/g")
            echo "$result"
        }

        size() {
            local file_path=$1
            local file_size=$(stat -c%s "$file_path")
            echo "$file_size"
        }


        lines() {
            local file_path=$1
            local line_count=$(wc -l < "$file_path")
            echo "$line_count"
        }
shell() {
    local command=$1
   
    # Check if the command starts with "expr"
    if [[ "$command" =~ ^'expr' ]]; then
        # If it starts with "expr", evaluate the expression using bc -l
        result=$(echo "${command:5}" | bc -l 2>&1)
    else
        # Otherwise, execute the command as is
        result=$(eval "$command" 2>&1)
    fi

    # Check for errors
    if [ $? -ne 0 ]; then
        echo "Error executing command: $command"
        echo "Command result: $result"
        return 1
    fi

    echo "$result"
}




inversion_feuille() {
    local nb_lignes=$(wc -l < "$input")
    local nb_colonnes=$(head -n 1 "$input" | tr -s ':' | tr ':' '\n' | wc -l)

    local result=""

    for col in $(seq 1 "$nb_colonnes"); do
        for row in $(seq 1 "$nb_lignes"); do
            local cell_value=$([cel] "l${row}c${col}")
            if [ -n "$cell_value" ]; then
                result+=" $cell_value"
            fi
        done
        result+="\n"
    done

    echo -e "$result" >>$output
}
 display() {
    local start_row=$(nb_lig "$1")
    local start_col=$(nb_cl "$1")
    local end_row=$(nb_lig "$2")
    local end_col=$(nb_cl "$2")

   if [[ $inverse == true ]]; then
        inversion_feuille
        return 
    fi
    for row in $(seq "$start_row" "$end_row"); do
        for col in $(seq "$start_col" "$end_col"); do
            local cell_value=$([cel] "l${row}c${col}")
            if [ -n "$cell_value" ]; then
                if [[ "$cell_value" =~ ^[0-9]+$ ]]; then
                    # Si la cellule contient uniquement des chiffres, afficher la valeur
                    echo -n "$cell_value ">>$output
                else
                    # Sinon, exécuter la valeur comme une commande
                    shell "$cell_value"
                fi
            fi
        done
        echo>>$output
    done
}
      

#EXEMMPLE DUTILISATION DE QLQ FONCTIONS
l=$([cel] "l1c3")
echo "$l"


# Test de la fonction somme
 test=$(somme l1c1 l2c3)
echo $test



#test_de_la fonction ecartype
resultat_ecart_type=$(ecarttype "l1c1" "l3c3")
echo "Écart type = $resultat_ecart_type"


#test de la fonction shell
shell 'expr (5 + 3)'

#test de Display
#test de la fonction display
inversion_feuille
 
    
    
    
    
    
    
    
    
    
    
    
    
    
    
 

