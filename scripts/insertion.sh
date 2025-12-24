db_path="$1"
tables_path="$db_path/tables"

read -p "Enter Table Name: " table_name

meta_file="$tables_path/$table_name.meta"
data_file="$tables_path/$table_name.db"

# Validate table existence
if [ ! -f "$meta_file" ]; then
    echo "Error: Table '$table_name' does not exist."
    exit 1
fi

if [ ! -f "$data_file" ]; then
    echo "Error: Data file for table '$table_name' does not exist."
    exit 1
fi

source "$meta_file"

# validate metadata
[[ ! "$pk" =~ ^[0-9]+$ ]] && echo "Corrupted metadata (pk)" && exit 1
[[ ! "$columns" =~ ^[0-9]+$ ]] && echo "Corrupted metadata (columns)" && exit 1

# Read metadata

IFS=':' read -ra  col_names <<< "$names"
IFS=':' read -ra  col_types <<< "$types"

row=()
pk_value=""

for ((i=0; i<columns; i++)); do
    read -p "Enter ${col_names[i]} (${col_types[i]}): " value

    # type validation
    if [ "${col_types[i]}" = "int" ]; then
        [[ ! "$value" =~ ^-?[0-9]+$ ]] && echo "Invalid integer for ${col_names[i]}" && exit 1
    else
        [ -z "$value" ] && echo "${col_names[i]} cannot be empty" && exit 1
    fi

    [ $((i+1)) -eq "$pk" ] && pk_value="$value"

    row+=("$value")
done

# Check for primary key uniqueness
if cut -d: -f"$pk" "$data_file" | grep -qx "$pk_value"; then
    echo "Error: Duplicate primary key value"
    exit 1
fi

echo "$(IFS=:; echo "${row[*]}")" >> "$data_file"

echo "Row inserted successfully"
