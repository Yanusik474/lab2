-- ============================================================
-- Лабораторная работа №2. Создание запросов
-- Вариант 24
-- ============================================================

BEGIN;

DROP TABLE IF EXISTS lab2_v24_surcharge CASCADE;

-- ============================================================
-- Задание 1.
-- Выбрать названия и цены за грамм корреспонденции,
-- сумма измерений которых по длине, ширине и высоте
-- превышает 30 см.
-- 30 см = 300 мм.
-- ============================================================
SELECT
    mt.mail_type_name AS "Вид корреспонденции",
    mc.distance AS "Расстояние",
    mc.price_per_gram AS "Цена за грамм",
    (mt.max_length_mm + mt.max_width_mm + mt.max_height_mm) AS "Сумма макс. размеров, мм"
FROM mail_types mt
JOIN mailing_costs mc ON mc.mail_type_code = mt.mail_type_code
WHERE (mt.max_length_mm + mt.max_width_mm + mt.max_height_mm) > 300
ORDER BY mt.mail_type_name, mc.distance;


-- ============================================================
-- Задание 2.
-- Выбрать виды корреспонденции, где наценка за срочность
-- больше 50% за отправку внутри страны.
-- ============================================================
SELECT
    mt.mail_type_name AS "Вид корреспонденции",
    mc.distance AS "Расстояние",
    mc.urgency_surcharge AS "Наценка за срочность",
    mc.packaging_price AS "Цена упаковки",
    mc.price_per_gram AS "Цена за грамм",
    mt.max_weight_g AS "Макс. вес, г",
    ROUND(
        mc.urgency_surcharge
        / NULLIF(mc.packaging_price + mc.price_per_gram * mt.max_weight_g, 0)
        * 100,
        2
    ) AS "Наценка, %"
FROM mail_types mt
JOIN mailing_costs mc ON mc.mail_type_code = mt.mail_type_code
WHERE mc.distance <> 'International'
  AND mc.urgency_surcharge > 0.5 * (
        mc.packaging_price + mc.price_per_gram * mt.max_weight_g
      )
ORDER BY mt.mail_type_name, mc.distance;


-- ============================================================
-- Задание 3.
-- Создать таблицу, содержащую данные 2 запроса
-- с указанием минимальных и максимальных размеров.
-- ============================================================
CREATE TABLE lab2_v24_surcharge AS
SELECT
    mt.mail_type_code,
    mt.mail_type_name,
    mc.distance,
    mc.price_per_gram,
    mc.packaging_price,
    mc.urgency_surcharge,
    mt.min_weight_g,
    mt.max_weight_g,
    mt.min_length_mm,
    mt.max_length_mm,
    mt.min_width_mm,
    mt.max_width_mm,
    mt.min_height_mm,
    mt.max_height_mm
FROM mail_types mt
JOIN mailing_costs mc ON mc.mail_type_code = mt.mail_type_code
WHERE mc.distance <> 'International'
  AND mc.urgency_surcharge > 0.5 * (
        mc.packaging_price + mc.price_per_gram * mt.max_weight_g
      );


-- ============================================================
-- Задание 4.
-- Добавить в созданную таблицу виды корреспонденции,
-- упаковывающиеся в коробки, максимальные размеры которых
-- не указаны.
--
-- Примечание:
-- в исходной схеме поля max_* имеют NOT NULL, поэтому
-- в текущих данных этот INSERT может добавить 0 строк.
-- Запрос написан корректно для случая, когда max_* могут быть NULL.
-- ============================================================
INSERT INTO lab2_v24_surcharge (
    mail_type_code,
    mail_type_name,
    distance,
    price_per_gram,
    packaging_price,
    urgency_surcharge,
    min_weight_g,
    max_weight_g,
    min_length_mm,
    max_length_mm,
    min_width_mm,
    max_width_mm,
    min_height_mm,
    max_height_mm
)
SELECT
    mt.mail_type_code,
    mt.mail_type_name,
    mc.distance,
    mc.price_per_gram,
    mc.packaging_price,
    mc.urgency_surcharge,
    mt.min_weight_g,
    mt.max_weight_g,
    mt.min_length_mm,
    mt.max_length_mm,
    mt.min_width_mm,
    mt.max_width_mm,
    mt.min_height_mm,
    mt.max_height_mm
FROM mail_types mt
JOIN mailing_costs mc ON mc.mail_type_code = mt.mail_type_code
WHERE mt.packaging = 'Box'
  AND (
        mt.max_length_mm IS NULL
     OR mt.max_width_mm IS NULL
     OR mt.max_height_mm IS NULL
  );


-- ============================================================
-- Задание 5.
-- В созданной таблице у всех видов корреспонденции,
-- соответствующих размерам формата A5 или меньше,
-- изменить название на «Письмо».
-- A5: 210 x 148 мм.
-- ============================================================
UPDATE lab2_v24_surcharge
SET mail_type_name = 'Письмо'
WHERE max_length_mm <= 210
  AND max_width_mm <= 148;


-- ============================================================
-- Задание 6.
-- Удалить из созданной таблицы все виды корреспонденции,
-- которые можно отправить только внутри страны.
-- То есть удаляем те mail_type_code, для которых
-- в mailing_costs нет ни одной строки с distance = 'International'.
-- ============================================================
DELETE FROM lab2_v24_surcharge t
WHERE NOT EXISTS (
    SELECT 1
    FROM mailing_costs mc
    WHERE mc.mail_type_code = t.mail_type_code
      AND mc.distance = 'International'
);


-- ============================================================
-- Задание 7.
-- Посчитать средний вес и размеры
-- для каждого наименования корреспонденции.
-- Средний вес = среднее между min_weight_g и max_weight_g.
-- Средние размеры = среднее между min_* и max_*.
-- ============================================================
SELECT
    mail_type_name AS "Наименование корреспонденции",
    ROUND(AVG((min_weight_g + max_weight_g) / 2.0), 2) AS "Средний вес, г",
    ROUND(AVG((min_length_mm + max_length_mm) / 2.0), 2) AS "Средняя длина, мм",
    ROUND(AVG((min_width_mm + max_width_mm) / 2.0), 2) AS "Средняя ширина, мм",
    ROUND(AVG((min_height_mm + max_height_mm) / 2.0), 2) AS "Средняя высота, мм"
FROM mail_types
GROUP BY mail_type_name
ORDER BY mail_type_name;


-- ============================================================
-- Проверка итоговой созданной таблицы
-- ============================================================
SELECT *
FROM lab2_v24_surcharge
ORDER BY mail_type_code, distance;

COMMIT;