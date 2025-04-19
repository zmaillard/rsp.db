-- +goose Up
-- +goose StatementBegin
ALTER TABLE sign.highway_name
ADD COLUMN state_id INTEGER CONSTRAINT highway_name_admin_area_state__fk references sign.admin_area_state (id);

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
ALTER TABLE sign.highway_name
DROP COLUMN state_id;

-- +goose StatementEnd
