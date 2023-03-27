# This SQL file was created to provide the config that must be added to all model.sql files.

{{ config(enabled = var('<package_name>_enabled',var('tuva_packages_enabled',True)) ) }}
