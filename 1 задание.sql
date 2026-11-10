--выбрать названия и цены за грамм корреспонденции, сумма измерений, сумма измерений которых по длине, ширине и высотепревышает 30см
SELECT DISTINCT mt."mail_type_name", mc."price_per_gram"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE (mt."max_length_mm" + mt."max_width_mm" + mt."max_height_mm") > 300;

--выбрать виды корреспонденции,где наценка за срочность больше 50% за отправку внутри страны
SELECT DISTINCT mt."mail_type_code", mt."mail_type_name"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE mc."distance" IN ('Up to 100 km', '100 to 1000 km')
  AND mc."urgency_surcharge" > 50;

--создать таблицу содержание данные двух вопросов с указанием минимальных и максимальных размеров
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

--добавит в созданную таблицу виды корреспонденции упоковывающиеся в коробки, максимальные размеры которые не указаны
INSERT INTO "selected_mail_types" 
("mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm")
SELECT "mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm"
FROM "mail_types"
WHERE "packaging" = 'Box'
  AND ("max_length_mm" IS NULL OR "max_width_mm" IS NULL OR "max_height_mm" IS NULL);
