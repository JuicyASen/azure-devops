using 'production.bicep'

param crossCuttingRG = 'rg-mpg-crs-seau'
param keyVaultName = 'kv-mpg-crs'
param sqlPSWDSecretName = 'sqldbpswd'

param UAMIDBACName =  'uami-mpg-prd-db-ac'
param UAMIKeyVaultACName =  'uami-mpg-crs-secrets-ac'
