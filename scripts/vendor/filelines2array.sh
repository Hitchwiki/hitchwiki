#!/bin/bash

# Use to read file lines into array
# https://gist.github.com/akwala/9013023

### Pretty-print dedicated (array) var, MAPFILE.
prettyPrintMAPFILE() {
  let i=0
  echo "[MAPFILE]"
  for l in "${MAPFILE[@]}"
  do
    echo "$i.   |$l|"
    let i++
  done
  echo "[/MAPFILE]"
}

### Read the lines of the specified file into an array.
##		Skips blank lines. Trims leading & trailing spaces in every line.
##		Resulting array is in the dedicated var, MAPFILE.
##	Params:
##		1.	File location to be read (required).
##		2.	Comment delimiter (optional; default: '#').
##+			-- to delimit any text that is to be omitted.
fileLines2Array() {
  if [[ -z "$1" ]] || [[ ! -e $1 ]]; then
    echo "File not provided or does not exist."
    return 1
  else
    echo "File to read: $1"
  fi

  commentPattern="\#*"
  [[ -n "$2" ]] && commentPattern="\\$2*"
  [[ -n "$commentPattern" ]] && echo "  ... will skip lines and trailing portions of lines beginning with this pattern: '$commentPattern'."

  mapfile -t < $1

  let i=0
  for l in "${MAPFILE[@]}"
  do
    echo $l
    l=${l%%$commentPattern}		# Remove trailing portion beginning with delimiter.
    l=${l%%*( )}				# Trim trailing spaces
    l=${l##*( )}				# Trim leading spaces
    if [[ -z "$l" ]]; then		# Remove line if it is empty/blank.
      unset MAPFILE[$i]
    else
      MAPFILE[$i]=$l			# Replace the line we read with its modified version.
      echo ${MAPFILE[$i]}
    fi
    let i++
  done

  return 0
}
