# @yaml
# signature: |-
#   edit <start_line>:<end_line> "<replacement_text>"
# docstring: replaces lines <start_line> through <end_line> (inclusive) with the given text in the open file. The replacement text should be provided as a string, with newlines preserved automatically. Python files will be checked for syntax errors after the edit. If the system detects a syntax error, the edit will not be executed. Simply try to edit the file again, but make sure to read the error message and modify the edit command you issue accordingly.
# end_name: end_of_edit
# arguments:
#   start_line:
#     type: integer
#     description: the line number to start the edit at
#     required: true
#   end_line:
#     type: integer
#     description: the line number to end the edit at (inclusive)
#     required: true
#   replacement_text:
#     type: string
#     description: the text to replace the current selection with, including any newline characters (multiline text will be handled automatically)
#     required: true
edit() {
    if [ -z "$CURRENT_FILE" ]; then
        echo 'No file open. Use the `open` command first.'
        return
    fi

    local start_line=$(echo "$1" | cut -d: -f1)
    local end_line=$(echo "$1" | cut -d: -f2)

    if [ -z "$start_line" ] || [ -z "$end_line" ]; then
        echo "Usage: edit <start_line>:<end_line> <replacement_text>"
        return
    fi

    local re='^[0-9]+$'
    if ! [[ $start_line =~ $re ]]; then
        echo "Error: start_line must be a number"
        return
    fi
    if ! [[ $end_line =~ $re ]]; then
        echo "Error: end_line must be a number"
        return
    fi

    local replacement_text="$2"
    if [ -z "$replacement_text" ]; then
        echo "Error: replacement_text cannot be empty"
        return
    fi

    local linter_cmd="flake8 --isolated --select=F821,F822,F831,E111,E112,E113,E999,E902"
    local linter_before_edit=$($linter_cmd "$CURRENT_FILE" 2>&1)

    # Adjust for 0-based indexing in arrays
    local start_line=$((start_line - 1))
    local end_line=$((end_line))

    # Split the `replacement_text` into an array by newlines
    IFS=$'\n'
    replacement=()
    while IFS= read -r line; do
        replacement+=("$line")
    done <<< "$replacement_text"

    # Backup current file in the current working directory
    cp "$CURRENT_FILE" "$(basename "$CURRENT_FILE")_backup"

    # Read the file line by line into an array (portable alternative to `mapfile`)
    lines=()
    while IFS= read -r line; do
        lines+=("$line")
    done < "$CURRENT_FILE"

    # Replace the specified lines
    local new_lines=("${lines[@]:0:$start_line}" "${replacement[@]}" "${lines[@]:$((end_line))}")
    
    # Write the new content into the original file
    printf "%s\n" "${new_lines[@]}" >| "$CURRENT_FILE"

    # Run linter
    if [[ $CURRENT_FILE == *.py ]]; then
        _lint_output=$($linter_cmd "$CURRENT_FILE" 2>&1)
        lint_output=$(_split_string "$_lint_output" "$linter_before_edit" "$((start_line+1))" "$end_line" "${#replacement[@]}")
    else
        lint_output=""
    fi

    # Handle linter output
    if [ -z "$lint_output" ]; then
        echo "File updated successfully."
    else
        echo "Your edit introduced syntax errors:"
        echo "$lint_output"
        cp "$(basename "$CURRENT_FILE")_backup" "$CURRENT_FILE"  # Restore the original file
        echo "Changes reverted. Please correct your edit."
    fi

    # Clean up backup
    rm -f "$(basename "$CURRENT_FILE")_backup"
}
