# Bash Shell Script Database Management System (DBMS)

A **Command-Line Interface (CLI) Database Management System** built entirely using Bash scripting.  
This project allows users to **create databases, manage tables, and perform CRUD operations** directly on disk using a simple menu-driven interface.


## Features

- **Database Management**
  - Create new databases
  - List existing databases
  - Connect to a specific database
  - Drop a database (to be implemented)

- **Table Management**
  - Create tables with custom columns and datatypes
  - List tables within a database
  - Drop tables
  - Insert data into tables with primary key validation
  - Select data (all or with conditions, numeric/string filters)
  - Delete records (by primary key or condition)
  - Update records (with datatype and primary key validation)

- **CLI Interface**
  - Menu-driven interface for easy navigation
  - Colored and padded output for readability
  - Validations for inputs (integers, strings, primary key uniqueness)


## Project Structure
```text
Bash_Project/
├── dbms.sh                 # Main menu script
├── README.md               # Project documentation
├── scripts/                # Folder containing all scripts
│   ├── create_database.sh
│   ├── list_database.sh
│   ├── connect_database.sh
│   ├── create_table.sh
│   ├── list_tables.sh
│   ├── drop_table.sh
│   ├── insert_into_table.sh
│   ├── select_from_table.sh
│   ├── delete_from_table.sh
│   └── update_table.sh
└── databases/              # Folder where all databases are stored
```


## Installation & Running the Project
1. Clone the repository:

```bash
git clone <https://github.com/Besso2003/DBMS-Using-Bash>
cd Bash_Project
```

2. Give execute permission to the main script (if needed)

```bash
chmod +x dbms.sh
```

3. Run the main menu:

```bash
./dbms.sh
```


Note: All databases will be stored in the databases/ folder created automatically by the script.

## Usage / Navigation
Main Menu Options
1) Create Database – Create a new database (folder).

2) List Database – Show all available databases.

3) Connect To Database – Enter a database to manage its tables.

4) Drop Database – Delete a database (not implemented yet).

5) Exit – Exit the application.


Database Menu (after connecting to a database)
1) Create Table – Define a new table with column names, datatypes, and primary key.

2) List Tables – List all tables in the connected database.

3) Drop Table – Delete a table.

4) Insert into Table – Add new records with datatype and primary key validation.

5) Select From Table – Display records (all or filtered by conditions).

6) Delete From Table – Remove records (by primary key or condition).

7) Update Table – Modify existing records with datatype validation.

Input Validations
- Integer columns accept only numbers.

- String columns accept only non-empty strings.

- Primary key uniqueness is enforced when inserting or updating records.

- Filter conditions support numeric ranges and exact string matches.

## Authors / Team

This project was developed by:

- Bassant Ali Kamal Ali – DevOps Engineering  
- Ibrahim Elsayed – DevOps Engineering

Both contributors collaborated to design, implement, and test this Bash Shell Script Database Management System (DBMS).
