#!/bin/bash

# =============================================================================
# Moodle Course Backup Script (Using Course Short Names)
# =============================================================================
# This script backs up specified Moodle courses by iterating through predefined
# course short names. For each short name, it queries the Moodle database to get
# the course ID and then performs the backup. It generates logs for monitoring
# and troubleshooting.
#
# =============================================================================
# Usage:
#   ./backup_moodle_courses.sh [course_shortnames_file]
#   - If a course short names file is provided as an argument, the script will load
#     course short names from that file (one short name per line). Otherwise, it will
#     use course short names defined within the script.
#
# =============================================================================

# ---------------------------
# Configuration Variables
# ---------------------------

# **Moodle Root Directory**
MOODLE_ROOT="/var/www/html/oukv2"

# **MySQL Credentials**
DB_HOST="localhost"                  # MySQL host
DB_USER="lmsuser"                    # MySQL username
DB_PASS="Lms@2050#"                  # MySQL password
DB_NAME="ouk_mdl"                    # MySQL database name

# **Backup Destination Directory**
DESTINATION_DIR="$HOME/backup"

# **Log File Location**
LOG_FILE="$DESTINATION_DIR/backup_$(date +'%Y%m%d').log"

# **Date Format for Logs**
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

# **Course Short Names Configuration**
# You can define course short names directly in the script or provide a file containing
# course short names (one per line).
#
# Example of defining course short names directly:
# COURSE_SHORTNAMES=("course_short1" "course_short2" "course_short3")
#
# Alternatively, to load course short names from an external file, pass the filename
# as the first argument when running the script.

# ---------------------------
# Function Definitions
# ---------------------------

# **Function to Log Messages**
log_message() {
    local MESSAGE="$1"
    echo "$(date "$DATE_FORMAT") : $MESSAGE" | tee -a "$LOG_FILE"
}

# **Function to Check Command Success**
check_success() {
    local EXIT_CODE=$1
    local SUCCESS_MSG="$2"
    local FAILURE_MSG="$3"
    if [ "$EXIT_CODE" -eq 0 ]; then
        log_message "$SUCCESS_MSG"
    else
        log_message "ERROR: $FAILURE_MSG"
        exit "$EXIT_CODE"
    fi
}

# **Function to Load Course Short Names**
load_course_shortnames() {
    local COURSE_FILE="$1"
    if [ -f "$COURSE_FILE" ]; then
        mapfile -t COURSE_SHORTNAMES < "$COURSE_FILE"
        log_message "Loaded course short names from file: $COURSE_FILE"
    else
        log_message "ERROR: Course short names file '$COURSE_FILE' not found."
        exit 1
    fi
}

# **Function to Query Course ID by Short Name**
get_course_id() {
    local SHORTNAME="$1"
    # Query the Moodle database for the course id based on shortname.
    local COURSE_ID
    COURSE_ID=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -se "SELECT id FROM mdl_course WHERE shortname = '$SHORTNAME' LIMIT 1;")
    echo "$COURSE_ID"
}

# ---------------------------
# Script Execution Starts Here
# ---------------------------

# **Start Logging**
mkdir -p "$DESTINATION_DIR"
touch "$LOG_FILE"
log_message "========== Moodle Course Backup Started =========="

# **Determine Source of Course Short Names**
if [ "$#" -ge 1 ]; then
    # If a course short names file is provided as an argument
    COURSE_FILE="$1"
    load_course_shortnames "$COURSE_FILE"
else
    # Define course short names directly within the script
    COURSE_SHORTNAMES=("PLA 711" "BEB 102" "DSC201")  # Replace with your actual course short names
    log_message "Using predefined course short names: ${COURSE_SHORTNAMES[*]}"
fi

# **Check if Course Short Names are Retrieved**
if [ "${#COURSE_SHORTNAMES[@]}" -eq 0 ]; then
    log_message "No course short names found to process. Exiting."
    exit 0
fi

# **Loop Through Each Course Short Name, Query for Course ID, and Perform Backup**
for SHORTNAME in "${COURSE_SHORTNAMES[@]}"; do
    log_message "Processing course short name: $SHORTNAME"
    
    # Get the course ID from the database based on short name
    COURSE_ID=$(get_course_id "$SHORTNAME")
    
    if [ -z "$COURSE_ID" ]; then
        log_message "ERROR: No course found with short name: $SHORTNAME"
        continue
    fi
    
    log_message "Found course ID: $COURSE_ID for short name: $SHORTNAME"
    
    # Execute the backup command and capture output and errors
    php "$MOODLE_ROOT/admin/cli/backup.php" --courseid="$COURSE_ID" --destination="$DESTINATION_DIR" --users=0 >> "$LOG_FILE" 2>&1
    EXIT_CODE=$?
    
    # Check if backup was successful
    if [ "$EXIT_CODE" -eq 0 ]; then
        log_message "Successfully backed up course '$SHORTNAME' (ID: $COURSE_ID)"
    else
        log_message "ERROR: Failed to back up course '$SHORTNAME' (ID: $COURSE_ID)"
        # Optionally, you can choose to exit or continue based on your requirements
        # exit "$EXIT_CODE"
    fi
done

log_message "========== Moodle Course Backup Completed =========="
exit 0
