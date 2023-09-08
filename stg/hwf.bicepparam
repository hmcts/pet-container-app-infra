using '../hwf.bicep'

param env = 'stg'
param publicSubmissionUrl = 'https://hwf-staff-stg.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-stg.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://hwf-laa-benefit-checker-stg.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param serviceNowEmail = 'DCD-HWFSupportServiceDeskPPE@HMCTS.NET'
param benefitApiPath = '/bc-DS_Dev/lsc-services/benefitChecker'
