#!/bin/bash
# LiveLabs Markdown Formatting Validator
# Validates markdown files against LiveLabs formatting standards

# Don't exit on first error - we want to check all files
set +e

ERRORS=0
WARNINGS=0

# Colors for output
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

log_error() {
    echo -e "${RED}ERROR${NC}: $1"
    ((ERRORS++))
}

log_warning() {
    echo -e "${YELLOW}WARNING${NC}: $1"
    ((WARNINGS++))
}

log_success() {
    echo -e "${GREEN}PASS${NC}: $1"
}

# Get markdown files from args, directory, or find all in current directory
if [ $# -gt 0 ]; then
    # Check if first argument is a directory
    if [ -d "$1" ]; then
        TARGET_DIR="$1"
        echo "Scanning directory: $TARGET_DIR"
        echo ""
        FILES=$(find "$TARGET_DIR" -name "*.md" -type f | grep -v node_modules | grep -v .github | sort)
    else
        # Treat arguments as individual files
        FILES="$@"
    fi
else
    FILES=$(find . -name "*.md" -type f | grep -v node_modules | grep -v .github | sort)
fi

# Check if any files were found
if [ -z "$FILES" ]; then
    echo "No markdown files found."
    exit 0
fi

echo "================================================"
echo "LiveLabs Markdown Formatting Validator"
echo "================================================"
echo ""

for file in $FILES; do
    if [ ! -f "$file" ]; then
        continue
    fi

    echo "Checking: $file"
    FILE_ERRORS=0

    # Rule 1: Check for H1 title (must be first non-empty line)
    first_content=$(grep -v '^$' "$file" | head -1)
    if [[ ! "$first_content" =~ ^#[^#] ]]; then
        log_error "$file: First line must be an H1 title (# Title)"
        ((FILE_ERRORS++))
    fi

    # Rule 2: Check for only one H1 per file (excluding code blocks)
    # Use awk to skip content inside fenced code blocks
    # Only match proper fenced code blocks: ``` alone or ```language (not inline code spans)
    h1_count=$(awk '
        /^[[:space:]]*```[[:space:]]*$/ || /^[[:space:]]*```[a-zA-Z]+[[:space:]]*$/ {
            in_code = !in_code
            next
        }
        !in_code && /^# / { count++ }
        END { print count+0 }
    ' "$file")
    if [ "$h1_count" -gt 1 ]; then
        log_error "$file: Multiple H1 headers found ($h1_count). Only one H1 allowed per file."
        ((FILE_ERRORS++))
    fi

    # Rule 3: Check for Acknowledgements section
    if ! grep -q "^## Acknowledgements" "$file"; then
        log_error "$file: Missing '## Acknowledgements' section"
        ((FILE_ERRORS++))
    fi

    # Rule 4: Check Acknowledgements format (Author/Authors with bold)
    if grep -q "^## Acknowledgements" "$file"; then
        if ! grep -A5 "^## Acknowledgements" "$file" | grep -qE '\*\*Authors?\*\*'; then
            log_warning "$file: Acknowledgements should include '**Author** - <Name, Title, Group>'"
        fi
    fi

    # Rule 5: Check image references have alt text
    # Pattern: ![](images/...) is invalid, should be ![alt text](images/...)
    if grep -n '!\[\]\s*(' "$file" | grep -v '^[0-9]*:.*!\[\](youtube:' > /dev/null 2>&1; then
        lines=$(grep -n '!\[\]\s*(' "$file" | grep -v '!\[\](youtube:' | cut -d: -f1 | tr '\n' ', ')
        log_error "$file (line $lines): Image references must have alt text: ![alt text](images/file.png)"
        ((FILE_ERRORS++))
    fi

    # Rule 6: Check YouTube format is correct
    if grep -E '\[.*\]\(youtube:' "$file" | grep -v '^\[]\(youtube:' > /dev/null 2>&1; then
        log_warning "$file: YouTube embeds should use format: [](youtube:VIDEO_ID)"
    fi

    # Rule 7: Check for proper Task format (## Task N: Description)
    task_headers=$(grep -n "^## Task" "$file" || true)
    if [ -n "$task_headers" ]; then
        while IFS= read -r line; do
            if [[ ! "$line" =~ ^[0-9]+:##\ Task\ [0-9]+: ]]; then
                linenum=$(echo "$line" | cut -d: -f1)
                log_warning "$file (line $linenum): Task headers should follow format '## Task N: Description'"
            fi
        done <<< "$task_headers"
    fi

    # Rule 8: Check <copy> tags are properly closed
    open_copy=$(grep -c '<copy>' "$file" || true)
    close_copy=$(grep -c '</copy>' "$file" || true)
    if [ "$open_copy" -ne "$close_copy" ]; then
        log_error "$file: Mismatched <copy> tags (open: $open_copy, close: $close_copy)"
        ((FILE_ERRORS++))
    fi

    # Rule 9: Check Note format
    if grep -n '^>' "$file" | grep -v '> \*\*Note:\*\*' > /dev/null 2>&1; then
        # This is a soft warning - blockquotes might be used for other purposes
        :
    fi

    # Rule 10: Check for Introduction or About section in labs
    if grep -q "^## Task" "$file"; then
        if ! grep -q "^## Introduction" "$file"; then
            log_warning "$file: Labs with Tasks should have an '## Introduction' section"
        fi
    fi

    # Rule 11: Check for Objectives section
    if ! grep -q "^### Objectives" "$file" && ! grep -q "^## Objectives" "$file"; then
        log_warning "$file: Consider adding an '### Objectives' section"
    fi

    # Rule 12 & 13: Check for Estimated Time
    basename_file=$(basename "$file")
    if [ "$basename_file" = "introduction.md" ]; then
        # Rule 13: introduction.md must have "Estimated Workshop Time:"
        if ! grep -q "Estimated Workshop Time:" "$file"; then
            log_error "$file: introduction.md must contain 'Estimated Workshop Time:'"
            ((FILE_ERRORS++))
        fi
    else
        # Rule 12: Other files must have "Estimated Time:"
        if ! grep -qi "Estimated.*Time:" "$file"; then
            log_error "$file: Missing 'Estimated Time:' information"
            ((FILE_ERRORS++))
        fi
    fi

    # Rule 14: Check filenames in image references are lowercase
    image_refs=$(grep -oE '!\[.*?\]\((images/[^)]+)\)' "$file" | grep -oE 'images/[^)]+' || true)
    for img in $image_refs; do
        lowercase_img=$(echo "$img" | tr '[:upper:]' '[:lower:]')
        if [ "$img" != "$lowercase_img" ]; then
            log_error "$file: Image filename should be lowercase: $img"
            ((FILE_ERRORS++))
        fi
    done

    # Rule 15: Check for Learn More section (optional but recommended)
    # Just a soft check, no warning

    if [ $FILE_ERRORS -eq 0 ]; then
        log_success "$file passed all required checks"
    fi
    echo ""
done

echo "================================================"
echo "Summary"
echo "================================================"
echo "Errors: $ERRORS"
echo "Warnings: $WARNINGS"
echo ""

if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation FAILED${NC}"
    exit 1
else
    echo -e "${GREEN}Validation PASSED${NC}"
    exit 0
fi