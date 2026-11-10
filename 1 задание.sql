--выбрать названия и цены за грамм корреспонденции, сумма измерений, сумма измерений которых по длине, ширине и высотепревышает 30см
SELECT DISTINCT mt."mail_type_name", mc."price_per_gram"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE (mt."max_length_mm" + mt."max_width_mm" + mt."max_height_mm") > 300;
