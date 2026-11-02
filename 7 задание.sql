SELECT "mail_type_name",
       AVG("min_weight_g") AS "avg_min_weight",
       AVG("max_weight_g") AS "avg_max_weight",
       AVG("min_length_mm") AS "avg_min_length",
       AVG("max_length_mm") AS "avg_max_length",
       AVG("min_width_mm") AS "avg_min_width",
       AVG("max_width_mm") AS "avg_max_width",
       AVG("min_height_mm") AS "avg_min_height",
       AVG("max_height_mm") AS "avg_max_height"
FROM "mail_types"
GROUP BY "mail_type_name";