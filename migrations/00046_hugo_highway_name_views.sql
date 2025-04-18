-- +goose Up
-- +goose StatementBegin
create
or replace view sign.vwhugostate (
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
) as
SELECT
    state.id,
    state.name AS state_name,
    state.slug AS state_slug,
    state.subdivision_name,
    statecount.image_count,
    highways.statehwys AS highways,
    places.stateplaces AS places,
    counties.statecounties AS counties,
    hs.imageid AS featured,
    c.slug AS country_slug,
    categories.categories,
    names.hwy_names AS highway_names
FROM
    sign.admin_area_state state
    JOIN (
        SELECT
            highwaysign.admin_area_state_id,
            count(*) AS image_count
        FROM
            sign.highwaysign
        GROUP BY
            highwaysign.admin_area_state_id
    ) statecount ON statecount.admin_area_state_id = state.id
    JOIN (
        SELECT
            hs_1.admin_area_state_id,
            array_agg (DISTINCT h.slug) AS statehwys
        FROM
            sign.highwaysign_highway hsh
            JOIN sign.highway h ON h.id = hsh.highway_id
            JOIN sign.highwaysign hs_1 ON hsh.highwaysign_id = hs_1.id
        GROUP BY
            hs_1.admin_area_state_id
    ) highways ON highways.admin_area_state_id = state.id
    LEFT JOIN (
        SELECT
            p.admin_area_stateid,
            json_agg (
                json_build_object ('slug', p.slug, 'name', p.name)
            ) AS stateplaces
        FROM
            sign.admin_area_place p
        GROUP BY
            p.admin_area_stateid
    ) places ON places.admin_area_stateid = state.id
    LEFT JOIN (
        SELECT
            c_1.admin_area_stateid,
            json_agg (
                json_build_object ('slug', c_1.slug, 'name', c_1.name)
            ) AS statecounties
        FROM
            sign.admin_area_county c_1
        GROUP BY
            c_1.admin_area_stateid
    ) counties ON counties.admin_area_stateid = state.id
    LEFT JOIN (
        SELECT
            a.admin_area_state_id,
            array_agg (DISTINCT a.slug) AS categories
        FROM
            (
                SELECT
                    hs_1.admin_area_state_id,
                    t.slug
                FROM
                    sign.tag_highwaysign ths
                    JOIN sign.tag t ON t.id = ths.tag_id
                    JOIN sign.highwaysign hs_1 ON hs_1.id = ths.highwaysign_id
                WHERE
                    t.is_category = true
            ) a
        GROUP BY
            a.admin_area_state_id
    ) categories ON state.id = categories.admin_area_state_id
    LEFT JOIN sign.highwaysign hs ON state.featured_sign_id = hs.id
    LEFT JOIN (
        SELECT
            f.admin_area_state_id as stateid,
            array_agg (distinct (slugify (hn.name))) as hwy_names
        FROM
            sign.feature_highway_name fhn
            INNER JOIN sign.feature f on fhn.feature_id = f.id
            INNER JOIN sign.highway_name hn on fhn.highway_name_id = hn.id
        GROUP BY
            f.admin_area_state_id
    ) names ON state.id = names.stateid
    JOIN sign.admin_area_country c ON state.adminarea_country_id = c.id;

 create or replace view sign.vwhugofeature (id, point, name, signs, state_name, state_slug, country_name, country_slug, highway_names) as
    SELECT f.id,
           f.point,
           f.name,
           signs.signs,
           s.name AS state_name,
           s.slug AS state_slug,
           c.name AS country_name,
           c.slug AS country_slug,
           names.hwy_names as highway_names
    FROM sign.feature f
             LEFT JOIN (SELECT hs.feature_id,
                               array_agg(hs.imageid::text) AS signs
                        FROM sign.highwaysign hs
                        GROUP BY hs.feature_id) signs ON f.id = signs.feature_id
             LEFT JOIN (SELECT fhn.feature_id,
                               array_agg(distinct hn.name) AS hwy_names
                        FROM sign.feature_highway_name fhn
                        INNER JOIN sign.highway_name hn on fhn.highway_name_id = hn.id
                        GROUP BY fhn.feature_id) names ON f.id = names.feature_id
             LEFT JOIN sign.admin_area_country c ON f.admin_area_country_id = c.id
             LEFT JOIN sign.admin_area_state s ON f.admin_area_state_id = s.id;


 create or replace view sign.vwhugofeaturelink (id, from_feature, to_feature, road_name, highways, to_point, from_point, highway_name) as
 SELECT fl.id,
        fl.from_feature,
        fl.to_feature,
        fl.road_name,
        cast(highways.highways as text[]) as highways,
        cast(tf.point as geometry) AS to_point,
        cast(ff.point AS geometry)  AS from_point,
        hn.name as highway_name
 FROM sign.feature_link fl
         LEFT JOIN sign.highway_name hn ON fl.highway_name_id = hn.id
          LEFT JOIN sign.feature tf ON fl.to_feature = tf.id
          LEFT JOIN sign.feature ff ON fl.from_feature = ff.id
          LEFT JOIN (SELECT flh.feature_link_id,
                            array_agg(h.slug) AS highways
                     FROM sign.feature_link_highway flh
                              JOIN sign.highway h ON flh.highway_id = h.id
                     GROUP BY flh.feature_link_id) highways ON fl.id = highways.feature_link_id;


-- +goose StatementEnd
-- +goose Down
-- +goose StatementBegin
DROP view sign.vwhugofeature;
DROP view sign.vwhugostate;
DROP view sign.vwhugofeaturelink;

create view sign.vwhugostate
            (id, state_name, state_slug, subdivision_name, image_count, highways, places, counties, featured,
             country_slug, categories)
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
       categories.categories
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
                           json_agg(json_build_object('slug', p.slug, 'name', p.name)) AS stateplaces
                    FROM sign.admin_area_place p
                    GROUP BY p.admin_area_stateid) places ON places.admin_area_stateid = state.id
         LEFT JOIN (SELECT c_1.admin_area_stateid,
                           json_agg(json_build_object('slug', c_1.slug, 'name', c_1.name)) AS statecounties
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
         JOIN sign.admin_area_country c ON state.adminarea_country_id = c.id;

         create view sign.vwhugofeature (id, point, name, signs, state_name, state_slug, country_name, country_slug) as
         SELECT f.id,
                f.point,
                f.name,
                signs.signs,
                s.name AS state_name,
                s.slug AS state_slug,
                c.name AS country_name,
                c.slug AS country_slug
         FROM sign.feature f
                  LEFT JOIN (SELECT hs.feature_id,
                                    array_agg(hs.imageid::text) AS signs
                             FROM sign.highwaysign hs
                             GROUP BY hs.feature_id) signs ON f.id = signs.feature_id
                  LEFT JOIN sign.admin_area_country c ON f.admin_area_country_id = c.id
                  LEFT JOIN sign.admin_area_state s ON f.admin_area_state_id = s.id;


         create view sign.vwhugofeaturelink (id, from_feature, to_feature, road_name, highways, to_point, from_point) as
                  SELECT fl.id,
                         fl.from_feature,
                         fl.to_feature,
                         fl.road_name,
                         cast(highways.highways as text[]) as highways,
                         cast(tf.point as geometry) AS to_point,
                         cast(ff.point AS geometry)  AS from_point
                  FROM sign.feature_link fl
                           LEFT JOIN sign.feature tf ON fl.to_feature = tf.id
                           LEFT JOIN sign.feature ff ON fl.from_feature = ff.id
                           LEFT JOIN (SELECT flh.feature_link_id,
                                             array_agg(h.slug) AS highways
                                      FROM sign.feature_link_highway flh
                                               JOIN sign.highway h ON flh.highway_id = h.id
                                      GROUP BY flh.feature_link_id) highways ON fl.id = highways.feature_link_id;

-- +goose StatementEnd
