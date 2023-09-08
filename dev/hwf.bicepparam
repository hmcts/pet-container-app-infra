using '../hwf.bicep'

param env = 'dev'
param publicSubmissionUrl = 'https://hwf-staff-int-dev.internal.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param dwpApiProxyUrl = 'https://hwf-benefit-checker-api-dev.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param laaBenefitCheckerUrl = 'https://hwf-laa-benefit-checker-dev.nicemushroom-6841cfc0.uksouth.azurecontainerapps.io'
param serviceNowEmail = 'DCD-HWFSupportServiceDeskDEV@HMCTS.NET'
param benefitApiPath = '/bc-DS_Dev/lsc-services/benefitChecker'

param publicDomainName = 'help-with-fees.dev.platform.hmcts.net'
param publicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-dev-rg/providers/Microsoft.App/managedEnvironments/petapps-dev/managedCertificates/mc-petapps-dev-help-with-fees-d-3422'

param staffPublicDomainName = 'staff.help-with-fees.dev.platform.hmcts.net'
param staffPublicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-dev-rg/providers/Microsoft.App/managedEnvironments/petapps-dev/managedCertificates/mc-petapps-dev-staff-help-with--2688'
