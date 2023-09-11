using '../hwf.bicep'

param env = 'prod'
param publicSubmissionUrl = 'https://hwf-staff-int-prod.internal.wonderfulmushroom-1f9e43ec.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-prod.wonderfulmushroom-1f9e43ec.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://benefitchecker.legalservices.gov.uk'
param serviceNowEmail = 'DCD-HWFSupportServiceDesk@HMCTS.NET'
param benefitApiPath = '/lsx/lsc-services/benefitChecker'

param notifyCompletedNewRefundTemplateId = 'c918b6d2-c3c8-4f41-96be-2ce23fa19747'
param notifyCompletedOnlineTemplateId = '8f6c9dfd-4ba2-40e2-a6c2-cabe14c229e9'
param notifyCompletedPaperTemplateId = '358f58e8-f3c5-4477-b6e0-ce188751a62f'
param notifyCompletedCyNewRefundTemplateId = 'fb8081f8-a945-480b-a852-3708decbff13'
param notifyCompletedCyOnlineTemplateId = '6c933b40-6664-4a70-8ad0-51b50f1aedd6'
param notifyCompletedCyPaperTemplateId = '1282277c-525b-4fb1-9a23-bab55fc1e082'
param notifyPasswordResetTemplateId = '6a1290da-2731-4949-b58a-f5e3e469473d'
param notifyDwpDownTemplateId = '12729281-2e10-426b-8601-24732d801e3b'

param staffPublicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-prod-rg/providers/Microsoft.App/managedEnvironments/petapps-prod/managedCertificates/mc-petapps-prod-staff-helpwithco-4940'
param staffPublicDomainName = 'staff.helpwithcourtfees.service.gov.uk'

param publicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-prod-rg/providers/Microsoft.App/managedEnvironments/petapps-prod/managedCertificates/mc-petapps-prod-helpwithcourtfee-3471'
param publicDomainName = 'helpwithcourtfees.service.gov.uk'
