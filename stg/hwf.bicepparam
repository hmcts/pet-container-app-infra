using '../hwf.bicep'

param env = 'stg'
param publicSubmissionUrl = 'https://hwf-staff-int-stg.internal.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-stg.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://hwf-laa-benefit-checker-stg.niceglacier-a3f52750.uksouth.azurecontainerapps.io'
param serviceNowEmail = 'DCD-HWFSupportServiceDeskPPE@HMCTS.NET'
param benefitApiPath = '/bc-DS_Dev/lsc-services/benefitChecker'

param publicDomainName = 'help-with-fees.staging.platform.hmcts.net'
param publicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-stg-rg/providers/Microsoft.App/managedEnvironments/petapps-stg/managedCertificates/mc-petapps-stg-help-with-fees-s-2945'

param staffPublicDomainName = 'staff.help-with-fees.staging.platform.hmcts.net'
param staffPublicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-stg-rg/providers/Microsoft.App/managedEnvironments/petapps-stg/managedCertificates/mc-petapps-stg-staff-help-with--7512'
