using 'production.bicep'

// param webAppUAMIName = 'uami-web-mpg-prd'
// param CrskeyVaultAccessUAMI = 'uami-mpg-crs-secrets-ac'
param dbAccessUAMIName =  'uami-mpg-prd-db-ac'
param crossCuttingRG = 'rg-mpg-crs-seau'
param keyVaultName = 'kv-mpg-crs'
param sqlPSWDSecretName = 'sqldbpswd'
