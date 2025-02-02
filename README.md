# Moodle Course Backup Script (Excluding User Data)

This script automates the backup of Moodle courses by their course short names. It queries the Moodle database to retrieve the corresponding course IDs and then uses Moodle's CLI backup tool to create a backup while excluding student/user data.

## Features

- **Course Identification by Short Name:**  
  The script accepts course short names and queries the Moodle database to get the corresponding course ID.

- **Exclusion of User Data:**  
  The backup is performed with user data excluded. This is achieved by passing the `--users=0` parameter to the backup command (verify that your Moodle version supports this flag).

- **Logging:**  
  All actions and errors are logged to a daily log file in the backup destination directory.

- **Flexible Configuration:**  
  The Moodle root directory, database credentials, backup destination, and course short names are configurable within the script or via an external file.

## Prerequisites

- **Moodle Environment:**  
  Ensure you have a working Moodle installation with CLI backup functionality available at `admin/cli/backup.php`.

- **MySQL Access:**  
  The script uses MySQL to query course information. Make sure the MySQL credentials provided in the script have access to the Moodle database.

- **PHP:**  
  The script invokes PHP to run Moodle’s CLI backup. Verify that PHP is installed and accessible from your command line.

- **Bash Shell:**  
  The script is written in Bash and requires a Unix-like environment.

## Setup

1. **Clone or Download the Script:**

   Save the script (e.g., `backup_moodle_courses.sh`) to your desired directory.

2. **Edit Configuration Variables:**

   Open the script and adjust the following variables as needed:
   
   - `MOODLE_ROOT` — Path to your Moodle installation (e.g., `/var/www/html/oukv2`).
   - `DB_HOST`, `DB_USER`, `DB_PASS`, `DB_NAME` — MySQL database connection details.
   - `DESTINATION_DIR` — Where backups and logs will be stored.
   - `COURSE_SHORTNAMES` — Default list of course short names (if not using an external file).

3. **File Permissions:**

   Make the script executable:
   ```bash
   chmod +x backup_moodle_courses.sh
   ```

## Usage

You can run the script in two ways:

### 1. Using an External File for Course Short Names

Create a text file (e.g., `courses.txt`) containing one course short name per line:
```
course_short1
course_short2
course_short3
```

Run the script by providing the filename as an argument:
```bash
./backup_moodle_courses.sh courses.txt
```

### 2. Using Predefined Course Short Names

If no file is provided as an argument, the script uses the predefined list of course short names defined within the script:
```bash
COURSE_SHORTNAMES=("course_short1" "course_short2" "course_short3")
```
Simply run:
```bash
./backup_moodle_courses.sh
```

## Logging

- The script creates a log file in the backup destination directory.
- The log file is named `backup_YYYYMMDD.log` (based on the current date).
- All operations, including errors and success messages, are appended to this file.

## Excluding User Data

- The script excludes user (student) data during the backup by including the `--users=0` parameter.
- Ensure your Moodle CLI backup supports this parameter. If not, modify your Moodle backup settings via the Moodle administration interface.

## Troubleshooting

- **Course Not Found:**  
  If a course short name is not found in the database, the script logs an error and skips that course.

- **Backup Failures:**  
  Review the log file in the backup directory for detailed error messages and troubleshooting information.

## Disclaimer

- **Testing:**  
  It is highly recommended to test the backup process in a development or staging environment before using it in production.

- **Data Integrity:**  
  This script relies on Moodle's CLI backup tool. Make sure to verify your backup settings and regularly test restore procedures to ensure data integrity.

## License

Specify your license here (if applicable).

---

This `README.md` should help users understand how to configure, run, and troubleshoot the Moodle Course Backup Script.
