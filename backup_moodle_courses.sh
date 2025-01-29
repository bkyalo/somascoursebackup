#!/bin/bash

# =============================================================================
# Moodle Course Backup Script
# =============================================================================
# This script backs up specified Moodle courses by iterating through predefined
# course IDs. It generates logs for monitoring and troubleshooting, and it uses
# separate variables for Moodle root directory, MySQL credentials, and course IDs
# for better security, maintainability, and flexibility.
#
# =============================================================================
# Usage:
#   ./backup_moodle_courses.sh [course_ids_file]
#   - If a course IDs file is provided as an argument, the script will load course
#     IDs from that file. Otherwise, it will use course IDs defined within the script.
#
# =============================================================================

# ---------------------------
# Configuration Variables
# ---------------------------

# **Moodle Root Directory**
MOODLE_ROOT="/path/to/moodle"

# **MySQL Credentials**
DB_HOST="localhost"                  # MySQL host
DB_USER="Username"                    # MySQL username
DB_PASS="Password"                  # MySQL password
DB_NAME="Database name"                    # MySQL database name

# **Backup Destination Directory**
DESTINATION_DIR="$HOME/backup"

# **Log File Location**
LOG_FILE="$DESTINATION_DIR/backup_$(date +'%Y%m%d').log"

# **Date Format for Logs**
DATE_FORMAT="+%Y-%m-%d %H:%M:%S"

# **Course IDs Configuration**
# You can define course IDs directly in the script or provide a file containing course IDs.
# To use a file, pass the filename as the first argument when running the script.

# Example of defining course IDs directly:
# COURSE_IDS=(925 926 927 928)

# Alternatively, to load course IDs from an external file:
# Ensure the file contains one course ID per line.

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

# **Function to Load Course IDs**
load_course_ids() {
    local COURSE_IDS_FILE="$1"
    if [ -f "$COURSE_IDS_FILE" ]; then
        mapfile -t COURSE_IDS < "$COURSE_IDS_FILE"
        log_message "Loaded course IDs from file: $COURSE_IDS_FILE"
    else
        log_message "ERROR: Course IDs file '$COURSE_IDS_FILE' not found."
        exit 1
    fi
}

# ---------------------------
# Script Execution Starts Here
# ---------------------------

# **Start Logging**
mkdir -p "$DESTINATION_DIR"
touch "$LOG_FILE"
log_message "========== Moodle Course Backup Started =========="

# **Determine Source of Course IDs**
if [ "$#" -ge 1 ]; then
    # If a course IDs file is provided as an argument
    COURSE_IDS_FILE="$1"
    load_course_ids "$COURSE_IDS_FILE"
else
    # Define course IDs directly within the script
    # Uncomment and modify the following line as needed
    COURSE_IDS=(925 926 927 928)  # Replace with your actual course IDs
    log_message "Using predefined course IDs: ${COURSE_IDS[*]}"
fi

# **Alternative: Fetch Course IDs from Database (Commented Out)**
# If you prefer to fetch course IDs from the database, uncomment the following block
# and comment out the direct definition or file loading above.

# log_message "Fetching course IDs from the database..."
# COURSE_IDS=$(mysql -h "$DB_HOST" -u "$DB_USER" -p"$DB_PASS" -D "$DB_NAME" -se "SELECT id FROM mdl_course WHERE id > 924;")
# check_success $? "Successfully fetched course IDs." "Failed to fetch course IDs from the database."

# **Check if Course IDs are Retrieved**
if [ "${#COURSE_IDS[@]}" -eq 0 ]; then
    log_message "No course IDs found to back up. Exiting."
    exit 0
fi

# **Loop Through Each Course ID and Perform Backup**
for ID in "${COURSE_IDS[@]}"; do
    log_message "Starting backup for course ID: $ID"
    
    # Execute the backup command and capture output and errors
    php "$MOODLE_ROOT/admin/cli/backup.php" --courseid="$ID" --destination="$DESTINATION_DIR" >> "$LOG_FILE" 2>&1
    EXIT_CODE=$?
    
    # Check if backup was successful
    if [ "$EXIT_CODE" -eq 0 ]; then
        log_message "Successfully backed up course ID: $ID"
    else
        log_message "ERROR: Failed to back up course ID: $ID"
        # Optionally, you can choose to exit or continue based on your requirements
        # exit "$EXIT_CODE"
    fi
done

log_message "========== Moodle Course Backup Completed =========="
exit 0
