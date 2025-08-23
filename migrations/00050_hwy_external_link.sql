-- +goose Up
-- +goose StatementBegin
ALTER TABLE sign.highway
ADD COLUMN external_link text;

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
ALTER TABLE sign.highway
DROP COLUMN external_link;

-- +goose StatementEnd
