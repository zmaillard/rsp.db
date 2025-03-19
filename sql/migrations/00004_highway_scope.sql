-- +goose Up
-- +goose StatementBegin
create table sign.highway_scope
(
    id  serial
        constraint highway_scope_pk
            primary key,
    scope varchar(50)
);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
drop table sign.highway_scope;

-- +goose StatementEnd
