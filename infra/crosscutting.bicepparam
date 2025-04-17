using 'crosscutting.bicep'

param secret_sqldb_pswd = readEnvironmentVariable('SQL_DB_PASSWORD', 'default_pswd')
param adminPrincipalId = '39afd08c-8821-4bba-afb9-a59ec45c533d'
param prdServicePrincipalId = '3ec75f76-ad4a-48a6-9a91-e1e3a7da2c8b'

param keyVaultAccessUAMIName = 'uami-mpg-crs-secrets-ac'
param keyVaultName = 'kv-mpg-crs'
