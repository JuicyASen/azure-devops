using 'production.bicep'

param crossCuttingRG = 'rg-mpg-crs-seau'
param keyVaultName = 'kv-mpg-crs'
param sqlPSWDSecretName = 'sqldbpswd'

param UAMIDBACName =  'uami-mpg-prd-db-ac'
param UAMIKeyVaultACName =  'uami-mpg-crs-secrets-ac'

// DBA Setting
param DBAGroupName =  'db-admin-mpg-prd'
param DBAGroupObjId =  'ca753bfd-3ddb-4760-946a-ff8b32803f93'
