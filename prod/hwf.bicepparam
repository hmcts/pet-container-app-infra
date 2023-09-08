using '../hwf.bicep'

param env = 'prod'
param publicSubmissionUrl = 'https://hwf-staff-int-prod.internal.wonderfulmushroom-1f9e43ec.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-prod.wonderfulmushroom-1f9e43ec.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://benefitchecker.legalservices.gov.uk'
param serviceNowEmail = 'DCD-HWFSupportServiceDesk@HMCTS.NET'
param benefitApiPath = '/lsx/lsc-services/benefitChecker'
