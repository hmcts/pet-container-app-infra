using '../wsproxy.bicep'

param env = 'dev'

param publicDomainName = 'wsproxy.dev.platform.hmcts.net'
param publicDomainCertificateId = '/subscriptions/58a2ce36-4e09-467b-8330-d164aa559c68/resourceGroups/pet-dev-rg/providers/Microsoft.App/managedEnvironments/petapps-dev/managedCertificates/wsproxy.dev.platform.hmcts.n-pet-dev--230916212212'
