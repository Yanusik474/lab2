INSERT INTO "selected_mail_types" 
("mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm")
SELECT "mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm"
FROM "mail_types"
WHERE "packaging" = 'Box'
  AND ("max_length_mm" IS NULL OR "max_width_mm" IS NULL OR "max_height_mm" IS NULL);