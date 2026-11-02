DROP TABLE IF EXISTS "selected_mail_types";

CREATE TABLE "selected_mail_types" AS
SELECT DISTINCT mt."mail_type_code", mt."mail_type_name",
       mt."min_length_mm", mt."max_length_mm",
       mt."min_width_mm", mt."max_width_mm",
       mt."min_height_mm", mt."max_height_mm",
       mt."min_weight_g", mt."max_weight_g"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE mc."distance" IN ('Up to 100 km', '100 to 1000 km')
  AND mc."urgency_surcharge" > 50;

ALTER TABLE "selected_mail_types" ADD PRIMARY KEY ("mail_type_code");