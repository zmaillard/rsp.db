## Database For RoadSign Pictures
Uses Goose for migrations.


## Setup A New Database
Create new database `CREATE DATABASE roadsign`

### Create Extensions
The extensions are not included in the database migration scripts, so they must be created manually.
```sql
CREATE EXTENSION postgis;
CREATE EXTENSION unaccent;
```

## Define Permissions
Creating three roles at the server level that can be granted to users at the database level.

### Administrator
Create a user that will be used to run the schema migrations.
```sql
CREATE ROLE admin WITH NOLOGIN;
GRANT CREATE ON DATABASE roadsign TO admin;
```
Then, log into that database and grant the admin user public schema access.
```sql
GRANT ALL ON SCHEMA public TO admin;
```

### Editor
Create a user role that will be used to edit data within the database.

```sql
CREATE ROLE editor WITH NOLOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO editor;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO editor;

-- Run this command after the initial data migration has been completed
GRANT USAGE ON SCHEMA sign TO editor;
```

### Reader
Create a user role that will be used to read data within the database.

```sql
CREATE ROLE reader WITH NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO reader;

-- Run this command after the initial data migration has been completed
GRANT USAGE ON SCHEMA sign TO reader;
```
