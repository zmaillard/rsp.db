-- +goose Up
-- +goose StatementBegin
ALTER TABLE sign.highway_type
ADD COLUMN display_name varchar(50);

ALTER TABLE sign.highway add display_name varchar(50);

CREATE
OR REPLACE VIEW sign.vwhugohighwaytype (
    id,
    highway_type_name,
    highway_type_slug,
    sort,
    imagecount,
    imageid,
    highways,
    country,
    display_name
) as
SELECT
    ht.id,
    ht.highway_type_name,
    ht.slug AS highway_type_slug,
    ht.sort,
    signcounts.imagecount,
    highwaysign.imageid,
    highwayagg.highways,
    aac.slug AS country,
    ht.display_name
FROM
    sign.highway_type ht
    JOIN sign.admin_area_country aac ON aac.id = ht.admin_area_country_id
    LEFT JOIN (
        SELECT
            signtype.highway_type_id,
            count(signtype.highwaysign_id) AS imagecount
        FROM
            (
                SELECT DISTINCT
                    hsh.highwaysign_id,
                    h.highway_type_id
                FROM
                    sign.highwaysign_highway hsh
                    JOIN sign.highway h ON h.id = hsh.highway_id
            ) signtype
        GROUP BY
            signtype.highway_type_id
    ) signcounts ON ht.id = signcounts.highway_type_id
    LEFT JOIN sign.highwaysign ON ht.display_image_id = highwaysign.id
    LEFT JOIN (
        SELECT
            highway.highway_type_id,
            array_agg (highway.slug) AS highways
        FROM
            sign.highway
        GROUP BY
            highway.highway_type_id
    ) highwayagg ON ht.id = highwayagg.highway_type_id;

    create or replace view sign.vwhugohighway
                (id, highway_name, slug, sort_number, image_name, highway_type_slug, highway_type_name, states, counties,
                 places, previous_features, next_features, display_name)
    as
    SELECT hwy.id,
           hwy.highway_name,
           hwy.slug,
           hwy.sort_number,
           hwy.image_name,
           ht.slug               AS highway_type_slug,
           ht.highway_type_name,
           hwyplaces.allstates   AS states,
           hwyplaces.allcounties AS counties,
           hwyplaces.allplaces   AS places,
           features.fromfeat     AS previous_features,
           features.tofeat       AS next_features,
           hwy.display_name      AS display_name
    FROM sign.highway hwy
             JOIN sign.highway_type ht ON hwy.highway_type_id = ht.id
             LEFT JOIN (SELECT h.id,
                               array_agg(orf.prev_feat) AS fromfeat,
                               array_agg(orf.next_feat) AS tofeat
                        FROM sign.highway h,
                             LATERAL sign.get_first_highway(h.id) gf(prev_feat, next_feat),
                             LATERAL sign.get_ordered_features(h.id, gf.prev_feat) orf(prev_feat, next_feat)
                        GROUP BY h.id) features ON hwy.id = features.id
             LEFT JOIN (SELECT hs.highway_id,
                               array_agg(DISTINCT places.slug) FILTER (WHERE places.slug IS NOT NULL)     AS allplaces,
                               array_agg(DISTINCT states.slug) FILTER (WHERE states.slug IS NOT NULL)     AS allstates,
                               array_agg(DISTINCT counties.slug) FILTER (WHERE counties.slug IS NOT NULL) AS allcounties
                        FROM sign.highwaysign_highway hs
                                 JOIN sign.highwaysign h ON h.id = hs.highwaysign_id
                                 LEFT JOIN (SELECT place.id                                            AS pid,
                                                   (state.slug::text || '_'::text) || place.slug::text AS slug
                                            FROM sign.admin_area_place place
                                                     JOIN sign.admin_area_state state ON place.admin_area_stateid = state.id) places
                                           ON h.admin_area_place_id = places.pid
                                 LEFT JOIN (SELECT county.id                                            AS cid,
                                                   (state.slug::text || '_'::text) || county.slug::text AS slug
                                            FROM sign.admin_area_county county
                                                     JOIN sign.admin_area_state state ON county.admin_area_stateid = state.id) counties
                                           ON h.admin_area_county_id = counties.cid
                                 LEFT JOIN sign.admin_area_state states ON h.admin_area_state_id = states.id
                        GROUP BY hs.highway_id) hwyplaces ON hwy.id = hwyplaces.highway_id
    WHERE hwyplaces.allstates IS NOT NULL;

-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP VIEW sign.vwhugohighwaytype;

CREATE VIEW sign.vwhugohighwaytype (
    id,
    highway_type_name,
    highway_type_slug,
    sort,
    imagecount,
    imageid,
    highways,
    country
) as
SELECT
    ht.id,
    ht.highway_type_name,
    ht.slug AS highway_type_slug,
    ht.sort,
    signcounts.imagecount,
    highwaysign.imageid,
    highwayagg.highways,
    aac.slug AS country
FROM
    sign.highway_type ht
    JOIN sign.admin_area_country aac ON aac.id = ht.admin_area_country_id
    LEFT JOIN (
        SELECT
            signtype.highway_type_id,
            count(signtype.highwaysign_id) AS imagecount
        FROM
            (
                SELECT DISTINCT
                    hsh.highwaysign_id,
                    h.highway_type_id
                FROM
                    sign.highwaysign_highway hsh
                    JOIN sign.highway h ON h.id = hsh.highway_id
            ) signtype
        GROUP BY
            signtype.highway_type_id
    ) signcounts ON ht.id = signcounts.highway_type_id
    LEFT JOIN sign.highwaysign ON ht.display_image_id = highwaysign.id
    LEFT JOIN (
        SELECT
            highway.highway_type_id,
            array_agg (highway.slug) AS highways
        FROM
            sign.highway
        GROUP BY
            highway.highway_type_id
    ) highwayagg ON ht.id = highwayagg.highway_type_id;

    DROP VIEW sign.vwhugohighway;
    create view sign.vwhugohighway
                (id, highway_name, slug, sort_number, image_name, highway_type_slug, highway_type_name, states, counties,
                 places, previous_features, next_features)
    as
    SELECT hwy.id,
           hwy.highway_name,
           hwy.slug,
           hwy.sort_number,
           hwy.image_name,
           ht.slug               AS highway_type_slug,
           ht.highway_type_name,
           hwyplaces.allstates   AS states,
           hwyplaces.allcounties AS counties,
           hwyplaces.allplaces   AS places,
           features.fromfeat     AS previous_features,
           features.tofeat       AS next_features
    FROM sign.highway hwy
             JOIN sign.highway_type ht ON hwy.highway_type_id = ht.id
             LEFT JOIN (SELECT h.id,
                               array_agg(orf.prev_feat) AS fromfeat,
                               array_agg(orf.next_feat) AS tofeat
                        FROM sign.highway h,
                             LATERAL sign.get_first_highway(h.id) gf(prev_feat, next_feat),
                             LATERAL sign.get_ordered_features(h.id, gf.prev_feat) orf(prev_feat, next_feat)
                        GROUP BY h.id) features ON hwy.id = features.id
             LEFT JOIN (SELECT hs.highway_id,
                               array_agg(DISTINCT places.slug) FILTER (WHERE places.slug IS NOT NULL)     AS allplaces,
                               array_agg(DISTINCT states.slug) FILTER (WHERE states.slug IS NOT NULL)     AS allstates,
                               array_agg(DISTINCT counties.slug) FILTER (WHERE counties.slug IS NOT NULL) AS allcounties
                        FROM sign.highwaysign_highway hs
                                 JOIN sign.highwaysign h ON h.id = hs.highwaysign_id
                                 LEFT JOIN (SELECT place.id                                            AS pid,
                                                   (state.slug::text || '_'::text) || place.slug::text AS slug
                                            FROM sign.admin_area_place place
                                                     JOIN sign.admin_area_state state ON place.admin_area_stateid = state.id) places
                                           ON h.admin_area_place_id = places.pid
                                 LEFT JOIN (SELECT county.id                                            AS cid,
                                                   (state.slug::text || '_'::text) || county.slug::text AS slug
                                            FROM sign.admin_area_county county
                                                     JOIN sign.admin_area_state state ON county.admin_area_stateid = state.id) counties
                                           ON h.admin_area_county_id = counties.cid
                                 LEFT JOIN sign.admin_area_state states ON h.admin_area_state_id = states.id
                        GROUP BY hs.highway_id) hwyplaces ON hwy.id = hwyplaces.highway_id
    WHERE hwyplaces.allstates IS NOT NULL;



ALTER TABLE sign.highway_type
DROP COLUMN display_name;

ALTER TABLE sign.highway
drop display_name;

-- +goose StatementEnd
