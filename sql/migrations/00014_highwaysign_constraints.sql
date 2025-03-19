-- +goose Up
-- +goose StatementBegin
alter table sign.admin_area_country add constraint admin_area_country_highwaysign_id_fk foreign key (featured_sign_id) references sign.highwaysign;

alter table sign.admin_area_state add constraint admin_area_state_highwaysign_id_fk foreign key (featured_sign_id) references sign.highwaysign;

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
ALTER TABLE sign.admin_area_country
DROP CONSTRAINT admin_area_country_highwaysign_id_fk;

ALTER TABLE sign.admin_area_state
DROP CONSTRAINT admin_area_state_highwaysign_id_fk;

-- +goose StatementEnd
