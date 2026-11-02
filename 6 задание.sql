DELETE FROM "selected_mail_types"
WHERE "mail_type_code" NOT IN (
    SELECT "mail_type_code" 
    FROM "mailing_costs" 
    WHERE "distance" IN ('Over 1000 km', 'International')
);