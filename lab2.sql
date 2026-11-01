-- ============================================================================
-- INITIAL SETUP: CREATE TABLES AND INSERT TEST DATA
-- ============================================================================

DROP TABLE IF EXISTS "mailing_costs" CASCADE;
DROP TABLE IF EXISTS "mail_types" CASCADE;
DROP TABLE IF EXISTS "selected_mail_types" CASCADE;

CREATE TABLE "mail_types" (
    "mail_type_code"   SERIAL        PRIMARY KEY,
    "mail_type_name"   VARCHAR(100)  NOT NULL,
    "packaging"        VARCHAR(100)  NOT NULL,
    "min_weight_g"     NUMERIC(10,2) NOT NULL CHECK ("min_weight_g" >= 0),
    "max_weight_g"     NUMERIC(10,2) NOT NULL CHECK ("max_weight_g" > 0),
    "min_length_mm"    NUMERIC(10,2) NOT NULL CHECK ("min_length_mm" >= 0),
    "min_width_mm"     NUMERIC(10,2) NOT NULL CHECK ("min_width_mm" >= 0),
    "min_height_mm"    NUMERIC(10,2) NOT NULL CHECK ("min_height_mm" >= 0),
    "max_length_mm"    NUMERIC(10,2) NOT NULL CHECK ("max_length_mm" > 0),
    "max_width_mm"     NUMERIC(10,2) NOT NULL CHECK ("max_width_mm" > 0),
    "max_height_mm"    NUMERIC(10,2) NOT NULL CHECK ("max_height_mm" > 0)
);

CREATE TABLE "mailing_costs" (
    "mail_type_code"         INTEGER       NOT NULL,
    "distance"               VARCHAR(50)   NOT NULL,
    "price_per_gram"         NUMERIC(10,4) NOT NULL CHECK ("price_per_gram" >= 0),
    "packaging_price"        NUMERIC(10,2) NOT NULL CHECK ("packaging_price" >= 0),
    "urgency_surcharge"      NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK ("urgency_surcharge" >= 0),
    "declared_value_allowed" BOOLEAN       NOT NULL DEFAULT FALSE,
    PRIMARY KEY ("mail_type_code", "distance"),
    CONSTRAINT fk_cost_mail_type FOREIGN KEY ("mail_type_code") REFERENCES "mail_types"("mail_type_code") ON DELETE CASCADE
);

INSERT INTO "mail_types" ("mail_type_name", "packaging", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm")
VALUES
('Letter',            'Envelope',        1,   100, 100, 50,  1, 353, 250,   5),
('Parcel wrapper',    'Bag',             1,  2000, 100, 50,  1, 450, 350,  80),
('Parcel',            'Box',           100, 10000, 100, 50, 10, 600, 500, 400),
('Registered letter', 'Envelope',        1,   100, 100, 50,  1, 353, 250,   5),
('Insured wrapper',   'Reinforced bag',  1,  2000, 100, 50,  1, 450, 350,  80);

INSERT INTO "mailing_costs" ("mail_type_code", "distance", "price_per_gram", "packaging_price", "urgency_surcharge", "declared_value_allowed")
VALUES
(1, 'up to 100 km',         0.0250,  15.00,  40.00, FALSE),
(1, '100 to 1000 km',       0.0350,  15.00,  50.00, FALSE),
(1, 'over 1000 km',         0.0450,  15.00,  60.00, FALSE),
(2, 'up to 100 km',         0.0400,  25.00,  60.00, FALSE),
(2, '100 to 1000 km',       0.0550,  25.00,  70.00, FALSE),
(3, 'up to 100 km',         0.0200,  50.00,  90.00, TRUE),
(3, '100 to 1000 km',       0.0300,  50.00, 110.00, TRUE),
(4, 'up to 100 km',         0.0300,  20.00,  55.00, FALSE),
(5, 'up to 100 km',         0.0450,  35.00,  80.00, TRUE);


-- ============================================================================
-- 1. Выбрать названия и цены за грамм корреспонденции, сумма измерений которых
-- по длине, ширине и высоте превышает 30 см.
-- ============================================================================
SELECT DISTINCT mt."mail_type_name", mc."price_per_gram"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE (mt."max_length_mm" + mt."max_width_mm" + mt."max_height_mm") > 300;


-- ============================================================================
-- 2. Выбрать виды корреспонденции, где наценка за срочность больше 50% за
-- отправку внутри страны.
-- ============================================================================
SELECT DISTINCT mt."mail_type_code", mt."mail_type_name"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE mc."distance" IN ('up to 100 km', '100 to 1000 km')
  AND mc."urgency_surcharge" > 50;


-- ============================================================================
-- 3. Создать таблицу, содержащую данные 2 запроса с указанием минимальных и
-- максимальных размеров.
-- ============================================================================
CREATE TABLE "selected_mail_types" AS
SELECT DISTINCT mt."mail_type_code", mt."mail_type_name",
       mt."min_length_mm", mt."max_length_mm",
       mt."min_width_mm", mt."max_width_mm",
       mt."min_height_mm", mt."max_height_mm",
       mt."min_weight_g", mt."max_weight_g"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE mc."distance" IN ('up to 100 km', '100 to 1000 km')
  AND mc."urgency_surcharge" > 50;

ALTER TABLE "selected_mail_types" ADD PRIMARY KEY ("mail_type_code");


-- ============================================================================
-- 4. Добавить в созданную таблицу виды корреспонденции, упаковывающиеся в
-- коробки, максимальные размеры которых не указаны.
-- ============================================================================
-- (Note: Original table has NOT NULL constraints on max dimensions, so this inserts 0 rows)
INSERT INTO "selected_mail_types" 
("mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm")
SELECT "mail_type_code", "mail_type_name", "min_weight_g", "max_weight_g", "min_length_mm", "min_width_mm", "min_height_mm", "max_length_mm", "max_width_mm", "max_height_mm"
FROM "mail_types"
WHERE "packaging" = 'Box'
  AND ("max_length_mm" IS NULL OR "max_width_mm" IS NULL OR "max_height_mm" IS NULL);


-- ============================================================================
-- 5. В созданной таблице у всех видов корреспонденции, соответствующих
-- размерам формата А5 или меньше, изменить название на «Письмо».
-- ============================================================================
-- (A5 dimensions: 210 x 148 mm. Using 'Letter' as English equivalent of 'Письмо')
UPDATE "selected_mail_types"
SET "mail_type_name" = 'Letter'
WHERE "max_length_mm" <= 210 AND "max_width_mm" <= 148;


-- ============================================================================
-- 6. Удалить из созданной таблицы все виды корреспонденции, которые можно
-- отправить только внутри страны.
-- ============================================================================
-- (Deletes rows that do NOT have an 'over 1000 km' international route)
DELETE FROM "selected_mail_types"
WHERE "mail_type_code" NOT IN (
    SELECT "mail_type_code" 
    FROM "mailing_costs" 
    WHERE "distance" = 'over 1000 km'
);


-- ============================================================================
-- 7. Посчитать средний вес и размеры для каждого наименования корреспонденции.
-- ============================================================================
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