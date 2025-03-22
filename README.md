## Database For RoadSign Pictures
Uses Goose for migrations.


## Setup A New Database
Create new database `CREATE DATABASE rsp`

## Define Permissions
Creating three roles at the server level that can be granted to users at the database level.

### Admin
Create a user that will be used to run the schema migrations.
```sql
CREATE ROLE admin WITH NOLOGIN;
GRANT CREATE ON DATABASE rsp TO admin;
```
Then, log into that database and grant the admin user public schema access.
```sql
GRANT ALL ON SCHEMA public TO admin;
```

### Create Extensions
The extensions are not included in the database migration scripts, so they must be created manually.
```sql
CREATE EXTENSION postgis;
CREATE EXTENSION unaccent;
```

### Create Roles
1. Read Only
2. R/W
3. Schema Editor
4. [Refer To](https://www.red-gate.com/simple-talk/featured/postgresql-basics-object-ownership-and-default-privileges/)

## Create Read Only User
```sql
GRANT CONNECT ON DATABASE rsp TO rsp_read;
GRANT pg_read_all_data TO rsp_read;
```

## Create Edit User
```sql
GRANT CONNECT ON DATABASE rsp TO rsp_edit;
GRANT pg_write_all_data TO rsp_edit;
```

## Add Extensions
```sql
CREATE EXTENSION postgis;
CREATE EXTENSION unaccent;
```

##

-- Define the admin role with permissions to create objects within the database
CREATE ROLE admin WITH LOGIN;
GRANT CREATE ON DATABASE your_database_name TO admin;

-- Define the editor role with permissions to create, update, and read data
CREATE ROLE editor WITH LOGIN;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO editor;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO editor;

-- Define the reader role with permissions to only read data
CREATE ROLE reader WITH LOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO reader;
