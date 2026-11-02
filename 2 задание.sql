SELECT DISTINCT mt."mail_type_code", mt."mail_type_name"
FROM "mail_types" mt
JOIN "mailing_costs" mc ON mt."mail_type_code" = mc."mail_type_code"
WHERE mc."distance" IN ('Up to 100 km', '100 to 1000 km')
  AND mc."urgency_surcharge" > 50;