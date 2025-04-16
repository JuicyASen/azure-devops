using 'crosscutting.bicep'

param secret_sqldb_pswd = readEnvironmentVariable('SQL_DB_PASSWORD', 'default_pswd')
param adminPrincipalId =  '39afd08c-8821-4bba-afb9-a59ec45c533d'
param prdServicePrincipalId =  '0f5c978a-d26a-40c6-82d2-50c5505bd547'

param webAppUAMIName =  'uami-web-mpg-prd'
param keyVaultName =  'kv-mpg-crs'
