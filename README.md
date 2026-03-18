# Bash Shell Script Database Management System (DBMS)

A **Command-Line Interface (CLI) & (GUI) Database Management System** built entirely using Bash scripting.  
This project allows users to **create databases, manage tables, and perform CRUD operations** directly on disk using a simple menu-driven interface.


## Features

- **Database Management**
  - Create new databases
  - List existing databases
  - Connect to a specific database
  - Drop a database
  - Exit

- **Table Management**
  - Create tables with custom columns and datatypes
  - List tables within a database
  - Drop tables
  - Insert data into tables with primary key validation
  - Select data (all or with conditions, numeric/string filters)
  - Delete records (by primary key or condition)
  - Update records (with datatype and primary key validation)
  - Exit

- **CLI Interface**
  - Menu-driven interface for easy navigation
  - Colored and padded output for readability
  - Validations for inputs (integers, strings, primary key uniqueness)


## Project Structure
```text
Bash_Project/
├── selector_mode.sh        # selector mode menu script
├── README.md               # Project documentation
├── scripts/                # Folder containing all scripts
│   ├── cli/                # CLI version scripts
│   │   ├── create_database.sh
│   │   ├── list_database.sh
│   │   ├── connect_database.sh
│   │   ├── create_table.sh
│   │   ├── list_tables.sh
│   │   ├── drop_table.sh
│   │   ├── insert_into_table.sh
│   │   ├── select_from_table.sh
│   │   ├── delete_from_table.sh
│   │   └── update_table.sh
│   │
│   └── gui/                # GUI version scripts
│       ├── create_database.sh
│       ├── list_database.sh
│       ├── connect_database.sh
│       ├── create_table.sh
│       ├── list_tables.sh
│       ├── drop_table.sh
│       ├── insert_into_table.sh
│       ├── select_from_table.sh
│       ├── delete_from_table.sh
│       └── update_table.sh
│
└── databases/              # Folder where all databases are stored
```


## Installation & Running the Project
1. Clone the repository:

```bash
git clone <https://github.com/Besso2003/DBMS-Using-Bash>
cd DBMS-Using-Bash
```

2. Give execute permission to the main script (if needed)

```bash
chmod -R 755 /DBMS-Using-Bash
```

3. Run the main menu:

```bash
./selector_moder.sh
```


Note: All databases will be stored in the databases/ folder created automatically by the script.

## Usage / Navigation
### Selector Mode Menu

| No. | Option | Description                                      |
|-----|--------|--------------------------------------------------|
| 1   | CLI    | Use the Command Line Interface version.          |
| 2   | GUI    | Use the Graphical User Interface version.        |
| 3   | Exit   | Exit the application.                            |

### Database Menu Options

| No. | Option               | Description                                      |
|-----|---------------------|--------------------------------------------------|
| 1   | Create Database     | Create a new database (folder).                  |
| 2   | List Databases      | Display all available databases.                 |
| 3   | Connect to Database | Access a database to manage its tables.          |
| 4   | Drop Database       | Delete an existing database.                     |
| 5   | Exit                | Exit the application.                            |


### Table Menu (After Connecting to a Database)

| No. | Option              | Description                                                                 |
|-----|--------------------|-----------------------------------------------------------------------------|
| 1   | Create Table       | Define a new table with column names, datatypes, and a primary key.        |
| 2   | List Tables        | Display all tables in the connected database.                              |
| 3   | Drop Table         | Delete an existing table.                                                  |
| 4   | Insert into Table  | Add new records with datatype and primary key validation.                  |
| 5   | Select From Table  | Retrieve and display records (all or filtered by conditions).              |
| 6   | Delete From Table  | Remove records (by primary key, condition, or delete all).                 |
| 7   | Update Table       | Modify existing records with datatype validation.                          |
| 8   | Exit               | Return to the main menu.                                                   |

### Input Validations
- Integer columns accept only numbers.

- String columns accept only non-empty strings.

- Primary key uniqueness is enforced when inserting or updating records.

- Filter conditions support numeric ranges and exact string matches.

## 🤝 Contributors 🎖️

<table>
  <tr>
    <td align="center">
      <a href="https://github.com/Besso2003">
        <img src="https://github.com/Besso2003.png" width="100px;" alt="Bassant Ali Kamal"/>
        <br />
        <sub><b>Bassant Ali Kamal</b></sub>
      </a>
      <br />
      ⚙️ ☁️ 🐧
      <br />
      <sub><i>DevOps Engineer</i></sub>
    </td>
    <td align="center">
      <a href="https://github.com/Ibrahim-Elsayed-27">
        <img src="https://github.com/Ibrahim-Elsayed-27.png" width="100px;" alt="Ibrahim Elsayed"/>
        <br />
        <sub><b>Ibrahim Elsayed</b></sub>
      </a>
      <br />
      ⚙️ ☁️ 🐧
      <br />
      <sub><i>DevOps Engineer</i></sub>
    </td>
  </tr>
</table>
