using '../hwf.bicep'

param env = 'dev'
param publicSubmissionUrl = 'https://hwf-staff-dev.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-dev.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://hwf-laa-benefit-checker-dev.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param serviceNowEmail = 'DCD-HWFSupportServiceDeskDEV@HMCTS.NET'
param benefitApiPath = '/bc-DS_Dev/lsc-services/benefitChecker'
