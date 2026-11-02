UPDATE "selected_mail_types"
SET "mail_type_name" = 'Letter'
WHERE "max_length_mm" <= 210 AND "max_width_mm" <= 148;