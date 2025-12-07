-- +goose Up
-- +goose StatementBegin
ALTER TABLE sign.highway
ADD COLUMN highway_parent_id INTEGER CONSTRAINT highway_highway_parent__fk references sign.highway (id);
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
ALTER TABLE sign.highway
DROP COLUMN highway_parent_id;
-- +goose StatementEnd
