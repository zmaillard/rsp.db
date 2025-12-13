-- +goose Up
-- +goose StatementBegin
DROP VIEW sign.vwhugostate;
create or replace view sign.vwhugostate
            (
             id,
             state_name,
             state_slug,
             subdivision_name,
             image_count,
             highways,
             places,
             counties,
             featured,
             country_slug,
             categories,
             highway_names
                )
as
SELECT state.id,
       state.name             AS state_name,
       state.slug             AS state_slug,
       state.subdivision_name,
       statecount.image_count,
       highways.statehwys     AS highways,
       places.stateplaces     AS places,
       counties.statecounties AS counties,
       hs.imageid             AS featured,
       c.slug                 AS country_slug,
       categories.categories,
       names.hwy_names        AS highway_names
FROM sign.admin_area_state state
         JOIN (SELECT highwaysign.admin_area_state_id,
                      count(*) AS image_count
               FROM sign.highwaysign
               GROUP BY highwaysign.admin_area_state_id) statecount ON statecount.admin_area_state_id = state.id
         JOIN (SELECT hs_1.admin_area_state_id,
                      array_agg(DISTINCT h.slug) AS statehwys
               FROM sign.highwaysign_highway hsh
                        JOIN sign.highway h ON h.id = hsh.highway_id
                        JOIN sign.highwaysign hs_1 ON hsh.highwaysign_id = hs_1.id
               GROUP BY hs_1.admin_area_state_id) highways ON highways.admin_area_state_id = state.id
         LEFT JOIN (SELECT p.admin_area_stateid,
                           json_agg(
                                   json_build_object('slug', p.slug, 'name', p.name)
                           ) AS stateplaces
                    FROM sign.admin_area_place p
                    GROUP BY p.admin_area_stateid) places ON places.admin_area_stateid = state.id
         LEFT JOIN (SELECT c_1.admin_area_stateid,
                           json_agg(
                                   json_build_object('slug', c_1.slug, 'name', c_1.name)
                           ) AS statecounties
                    FROM sign.admin_area_county c_1
                    GROUP BY c_1.admin_area_stateid) counties ON counties.admin_area_stateid = state.id
         LEFT JOIN (SELECT a.admin_area_state_id,
                           array_agg(DISTINCT a.slug) AS categories
                    FROM (SELECT hs_1.admin_area_state_id,
                                 t.slug
                          FROM sign.tag_highwaysign ths
                                   JOIN sign.tag t ON t.id = ths.tag_id
                                   JOIN sign.highwaysign hs_1 ON hs_1.id = ths.highwaysign_id
                          WHERE t.is_category = true) a
                    GROUP BY a.admin_area_state_id) categories ON state.id = categories.admin_area_state_id
         LEFT JOIN sign.highwaysign hs ON state.featured_sign_id = hs.id
         LEFT JOIN ( select admin_area_state_id as stateid, array_agg(distinct hn) as hwy_names from (select ff.admin_area_state_id, sign.slugify(highway_name.name) as hn
               from sign.highway_name
                        inner join sign.feature_link on highway_name.id = feature_link.highway_name_id
                        inner join sign.feature ff on ff.id = feature_link.from_feature
               union all
               select tf.admin_area_state_id, sign.slugify(highway_name.name) as hn
               from sign.highway_name
                        inner join sign.feature_link on highway_name.id = feature_link.highway_name_id
                        inner join sign.feature tf on tf.id = feature_link.to_feature) i
            group by admin_area_state_id)  names ON state.id = names.stateid
         JOIN sign.admin_area_country c ON state.adminarea_country_id = c.id;
-- +goose StatementEnd

-- +goose Down
-- +goose StatementBegin
DROP VIEW sign.vwhugostate;
create or replace view sign.vwhugostate
            (
             id,
             state_name,
             state_slug,
             subdivision_name,
             image_count,
             highways,
             places,
             counties,
             featured,
             country_slug,
             categories,
             highway_names
                )
as
SELECT state.id,
       state.name             AS state_name,
       state.slug             AS state_slug,
       state.subdivision_name,
       statecount.image_count,
       highways.statehwys     AS highways,
       places.stateplaces     AS places,
       counties.statecounties AS counties,
       hs.imageid             AS featured,
       c.slug                 AS country_slug,
       categories.categories,
       names.hwy_names        AS highway_names
FROM sign.admin_area_state state
         JOIN (SELECT highwaysign.admin_area_state_id,
                      count(*) AS image_count
               FROM sign.highwaysign
               GROUP BY highwaysign.admin_area_state_id) statecount ON statecount.admin_area_state_id = state.id
         JOIN (SELECT hs_1.admin_area_state_id,
                      array_agg(DISTINCT h.slug) AS statehwys
               FROM sign.highwaysign_highway hsh
                        JOIN sign.highway h ON h.id = hsh.highway_id
                        JOIN sign.highwaysign hs_1 ON hsh.highwaysign_id = hs_1.id
               GROUP BY hs_1.admin_area_state_id) highways ON highways.admin_area_state_id = state.id
         LEFT JOIN (SELECT p.admin_area_stateid,
                           json_agg(
                                   json_build_object('slug', p.slug, 'name', p.name)
                           ) AS stateplaces
                    FROM sign.admin_area_place p
                    GROUP BY p.admin_area_stateid) places ON places.admin_area_stateid = state.id
         LEFT JOIN (SELECT c_1.admin_area_stateid,
                           json_agg(
                                   json_build_object('slug', c_1.slug, 'name', c_1.name)
                           ) AS statecounties
                    FROM sign.admin_area_county c_1
                    GROUP BY c_1.admin_area_stateid) counties ON counties.admin_area_stateid = state.id
         LEFT JOIN (SELECT a.admin_area_state_id,
                           array_agg(DISTINCT a.slug) AS categories
                    FROM (SELECT hs_1.admin_area_state_id,
                                 t.slug
                          FROM sign.tag_highwaysign ths
                                   JOIN sign.tag t ON t.id = ths.tag_id
                                   JOIN sign.highwaysign hs_1 ON hs_1.id = ths.highwaysign_id
                          WHERE t.is_category = true) a
                    GROUP BY a.admin_area_state_id) categories ON state.id = categories.admin_area_state_id
         LEFT JOIN sign.highwaysign hs ON state.featured_sign_id = hs.id
         LEFT JOIN (SELECT f.admin_area_state_id                  as stateid,
                           array_agg(distinct (sign.slugify(hn.name))) as hwy_names
                    FROM sign.feature_highway_name fhn
                             INNER JOIN sign.feature f on fhn.feature_id = f.id
                             INNER JOIN sign.highway_name hn on fhn.highway_name_id = hn.id
                    GROUP BY f.admin_area_state_id) names ON state.id = names.stateid
         JOIN sign.admin_area_country c ON state.adminarea_country_id = c.id;
-- +goose StatementEnd
