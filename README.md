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

GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO www;
ALTER DEFAULT PRIVILEGES IN SCHEMA public
    GRANT USAGE, SELECT ON SEQUENCES TO www;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO editor;
GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA sign TO editor;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO editor;

-- Run this command after the initial data migration has been completed
GRANT USAGE ON SCHEMA sign TO editor;
```

### Reader
Create a user role that will be used to read data within the database.

```sql
CREATE ROLE reader WITH NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO reader;
GRANT SELECT ON ALL TABLES IN SCHEMA sign TO reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO reader;
ALTER DEFAULT PRIVILEGES IN SCHEMA sign GRANT SELECT ON TABLES TO reader;

-- Run this command after the initial data migration has been completed
GRANT USAGE ON SCHEMA sign TO reader;
```

### Create Users
Create users that will be used to access the database and grant them the appropriate roles.  For examples:

```sql
CREATE USER rsp_admin WITH PASSWORD 'password';
GRANT admin TO rsp_admin;

CREATE USER rsp_editor WITH PASSWORD 'password';
GRANT editor TO rsp_editor;

CREATE USER rsp_reader WITH PASSWORD 'password';
GRANT reader TO rsp_reader;
```


## Creating Database
```sql

-- Assumes three users in database
-- App User (CRUD) - lambda_prod
-- App Owner (DDL) - rsp_owner
-- Superuser -- converseadmin
create database rsp;
create role edituser nologin;
grant edituser to lambda_prod;
grant edituser to converseadmin;

create role rspadmin nologin;
grant rsp_user to rspadmin;
grant rspadmin to converseadmin;

ALTER SCHEMA sign OWNER TO rspadmin;

GRANT USAGE ON SCHEMA sign TO edituser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA sign TO edituser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA sign TO edituser;
```

## Setting Up Initial Database
```sql
create extension postgis;


```

## Dump Database
```sql
pg_dump -h localhost rsp -O  -F c -n sign  -x  -f out.database
```

## Fix Sequence Ids
```sql
SELECT SETVAL('sign.admin_area_country_id_seq', (SELECT MAX(id) FROM sign.admin_area_country));
SELECT SETVAL('sign.admin_area_county_id_seq', (SELECT MAX(id) FROM sign.admin_area_county));
SELECT SETVAL('sign.admin_area_place_id_seq', (SELECT MAX(id) FROM sign.admin_area_place));
SELECT SETVAL('sign.admin_area_state_id_seq', (SELECT MAX(id) FROM sign.admin_area_state));
SELECT SETVAL('sign.feature_id_seq', (SELECT MAX(id) FROM sign.feature));
SELECT SETVAL('sign.feature_link_alias_id_seq', (SELECT MAX(id) FROM sign.feature_link_alias));
SELECT SETVAL('sign.feature_link_highway_id_seq', (SELECT MAX(id) FROM sign.feature_link_highway));
SELECT SETVAL('sign.feature_link_id_seq', (SELECT MAX(id) FROM sign.feature_link));
SELECT SETVAL('sign.flickr_set_id_seq', (SELECT MAX(id) FROM sign.flickr_set));
SELECT SETVAL('sign.highway_id_seq', (SELECT MAX(id) FROM sign.highway));
SELECT SETVAL('sign.highway_scope_id_seq', (SELECT MAX(id) FROM sign.highway_scope));
SELECT SETVAL('sign.highway_type_id_seq', (SELECT MAX(id) FROM sign.highway_type));
SELECT SETVAL('sign.highwaysign_highway_id_seq', (SELECT MAX(id) FROM sign.highwaysign_highway));
SELECT SETVAL('sign.highwaysign_id_seq', (SELECT MAX(id) FROM sign.highwaysign));
SELECT SETVAL('sign.tag_highwaysign_id_seq', (SELECT MAX(id) FROM sign.tag_highwaysign));
SELECT SETVAL('sign.tag_id_seq', (SELECT MAX(id) FROM sign.tag));
```
