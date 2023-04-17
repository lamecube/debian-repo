#!/bin/bash

function update_readme_usage_section {
    # Usage: update_readme_usage_section <flag_doc_file> <readme_file>

    flag_doc_file=$1
    readme_file=$2

    # Get the flag from the flag_doc_file
    flag=$(grep -oP '(?<=Flag:\s)(-[^, ]*|, --[^, ]*)' "$flag_doc_file")

    # Check if the flag already exists in the README
    if grep -q "$flag" "$readme_file"; then
        echo "Flag already exists in README"
        return
    fi

    # Get the flag description from the flag_doc_file
    description=$(sed -n '/^#/,$p' "$flag_doc_file" | grep -v "^#" | sed -E 's/^ *//')

    # Generate the usage section text
    usage_section_text="### \`$flag\`: \n >&emsp;$description"

    # Append the usage section to the README
    echo -e "\n$usage_section_text" >> "$readme_file"
}