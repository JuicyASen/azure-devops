using 'crosscutting.bicep'

param secret_sqldb_pswd = readEnvironmentVariable('SQL_DB_PASSWORD', 'default_pswd')
param adminPrincipalId =  '39afd08c-8821-4bba-afb9-a59ec45c533d'
