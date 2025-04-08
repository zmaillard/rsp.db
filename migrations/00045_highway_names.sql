-- +goose Up
-- +goose StatementBegin
CREATE TABLE sign.highway_name (
    id serial CONSTRAINT highway_names_pk PRIMARY KEY,
    name text
);

CREATE TABLE sign.highway_highway_name (
    id serial constraint highway_highway_name_highway_pk primary key,
    highway_id integer constraint highway_highway_id_fk references sign.highway,
    highway_name_id integer constraint highway_highway_name_id_fk references sign.highway_name
);

CREATE TABLE sign.feature_highway_name (
    id serial constraint feature_highway_name_pk primary key,
    feature_id integer constraint feature_highway_name_feature_id_fk references sign.feature,
    highway_name_id integer constraint feature_highway_name_highway_name_id_fk references sign.highway_name
);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP TABLE sign.feature_highway_name;

DROP TABLE sign.highway_highway_name;

DROP TABLE sign.highway_name;

-- +goose StatementEnd
