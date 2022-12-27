include {
  path = find_in_parent_folders()
}

terraform {
  source = "git::https://code.rbi.tech/raiffeisen/ua-avalaunch-terraform-modules.git//elasticache-multiple?ref=elasticache-multiple_v1.0.0"

  before_hook "before_hook" {
    commands = ["apply"]
    execute  = ["bash", "-c", "mkdir -p ~/.kube"]
  }
}

locals {
  # Automatically load common tags from parent hcl
  common_tags  = read_terragrunt_config(find_in_parent_folders("tags.hcl"))
  account_vars = read_terragrunt_config(find_in_parent_folders("account.hcl"))

  # Extract out common tags for reuse
  tags_map = local.common_tags.locals
}

inputs = {

  kubeconfig_path  = "/home/ssm-user/.kube/config"
  subnets_names    = ["LZ-AVAL_AVALAUNCH_DEV-RestrictedB", "LZ-AVAL_AVALAUNCH_DEV-RestrictedA", "LZ-AVAL_AVALAUNCH_DEV-RestrictedC"]
  tags             = local.tags_map

  additional_security_group_rules = [
    {
      type              = "ingress"
      from_port         = 6379
      to_port           = 6379
      protocol          = "tcp"
      cidr_blocks       = ["100.124.48.0/22", "100.124.52.0/22", "100.124.56.0/22"]
    }
  ]

  elasticache = [
# DMZ environment
    {
        redis_database_name       = "auth-dmz-dev"
        kubernetes_namespace_name = "auth-dmz-dev"
        environment               = "dev"
        domain_name               = "auth-dmz"
        service_name              = "auth"
    },
    {
        redis_database_name       = "auth-dmz-uat"
        kubernetes_namespace_name = "auth-dmz-uat"
        environment               = "uat"
        domain_name               = "auth-dmz"
        service_name              = "auth"
    },
    {
        redis_database_name       = "boot-admin-dmz-dev"
        kubernetes_namespace_name = "cards-dmz-dev"
        environment               = "dev"
        domain_name               = "cards-dmz"
        service_name              = "boot-admin"
    },
    {
        redis_database_name       = "boot-admin-dmz-uat"
        kubernetes_namespace_name = "cards-dmz-uat"
        environment               = "uat"
        domain_name               = "cards-dmz"
        service_name              = "boot-admin"
    },
    {
        redis_database_name       = "myraif-bff-auth-dmz-dev"
        kubernetes_namespace_name = "channel-mobile-dmz-dev"
        environment               = "dev"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-auth"
    },
    {
        redis_database_name       = "myraif-bff-card2card-dmz-dev"
        kubernetes_namespace_name = "channel-mobile-dmz-dev"
        environment               = "dev"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-card2card"
    },
    {
        redis_database_name       = "myraif-bff-cards-dmz-dev"
        kubernetes_namespace_name = "channel-mobile-dmz-dev"
        environment               = "dev"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-cards"
    },
    {
        redis_database_name       = "myraif-bff-onboarding-dmz-dev"
        kubernetes_namespace_name = "channel-mobile-dmz-dev"
        environment               = "dev"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-onboarding"
    },
    {
        redis_database_name       = "myraif-bff-payment-dmz-dev"
        kubernetes_namespace_name = "channel-mobile-dmz-dev"
        environment               = "dev"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-payment"
    },
    {
        redis_database_name       = "myraif-bff-auth-dmz-uat"
        kubernetes_namespace_name = "channel-mobile-dmz-uat"
        environment               = "uat"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-auth"
    },
    {
        redis_database_name       = "myraif-bff-card2card-dmz-uat"
        kubernetes_namespace_name = "channel-mobile-dmz-uat"
        environment               = "uat"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-card2card"
    },
    {
        redis_database_name       = "myraif-bff-cards-dmz-uat"
        kubernetes_namespace_name = "channel-mobile-dmz-uat"
        environment               = "uat"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-cards"
    },
    {
        redis_database_name       = "myraif-bff-onboarding-dmz-uat"
        kubernetes_namespace_name = "channel-mobile-dmz-uat"
        environment               = "uat"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-onboarding"
    },
    {
        redis_database_name       = "myraif-bff-payment-dmz-uat"
        kubernetes_namespace_name = "channel-mobile-dmz-uat"
        environment               = "uat"
        domain_name               = "channel-mobile-dmz"
        service_name              = "myraif-bff-payment"
    },
    {
        redis_database_name       = "aval-ua-dmz-dev"
        kubernetes_namespace_name = "channels-dmz-dev"
        environment               = "dev"
        domain_name               = "channels-dmz"
        service_name              = "aval-ua"
    },
    {
        redis_database_name       = "aval-ua-dmz-uat"
        kubernetes_namespace_name = "channels-dmz-uat"
        environment               = "uat"
        domain_name               = "channels-dmz"
        service_name              = "aval-ua"
    },
    {
        redis_database_name       = "channels-web-dmz-gateway-dmz-dev"
        kubernetes_namespace_name = "channels-web-dmz-dev"
        environment               = "dev"
        domain_name               = "channels-web-dmz"
        service_name              = "channels-web-dmz-gateway"
    },
    {
        redis_database_name       = "pe-onboarding-web-bff-dmz-dev"
        kubernetes_namespace_name = "channels-web-dmz-dev"
        environment               = "dev"
        domain_name               = "channels-web-dmz"
        service_name              = "pe-onboarding-web-bff"
    },
    {
        redis_database_name       = "system-tests-dmz-dev"
        kubernetes_namespace_name = "channels-web-dmz-dev"
        environment               = "dev"
        domain_name               = "channels-web-dmz"
        service_name              = "system-tests"
    },
    {
        redis_database_name       = "channels-web-dmz-gateway-dmz-uat"
        kubernetes_namespace_name = "channels-web-dmz-uat"
        environment               = "uat"
        domain_name               = "channels-web-dmz"
        service_name              = "channels-web-dmz-gateway"
    },
    {
        redis_database_name       = "pe-onboarding-web-bff-dmz-uat"
        kubernetes_namespace_name = "channels-web-dmz-uat"
        environment               = "uat"
        domain_name               = "channels-web-dmz"
        service_name              = "pe-onboarding-web-bff"
    },
    {
        redis_database_name       = "system-tests-dmz-uat"
        kubernetes_namespace_name = "channels-web-dmz-uat"
        environment               = "uat"
        domain_name               = "channels-web-dmz"
        service_name              = "system-tests"
    },
    {
        redis_database_name       = "diia-gateway-dmz-dev"
        kubernetes_namespace_name = "clients-dmz-dev"
        environment               = "dev"
        domain_name               = "clients-dmz"
        service_name              = "diia-gateway"
    },
    {
        redis_database_name       = "diia-gateway-dmz-uat"
        kubernetes_namespace_name = "clients-dmz-uat"
        environment               = "uat"
        domain_name               = "clients-dmz"
        service_name              = "diia-gateway"
    },
    {
        redis_database_name       = "sentry-dmz-dev"
        kubernetes_namespace_name = "infra-resources-dmz-dev"
        environment               = "dev"
        domain_name               = "infra-resoources-dmz"
        service_name              = "sentry"
    },
    {
        redis_database_name       = "sentry-dmz-uat"
        kubernetes_namespace_name = "infra-resources-dmz-uat"
        environment               = "uat"
        domain_name               = "infra-resoources-dmz"
        service_name              = "sentry"
    },
    {
        redis_database_name       = "back-office-dmz-dev"
        kubernetes_namespace_name = "pi-cc-lending-dmz-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-dmz"
        service_name              = "back-office"
    },
    {
        redis_database_name       = "credit-card-lending-api-dmz-dev"
        kubernetes_namespace_name = "pi-cc-lending-dmz-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-dmz"
        service_name              = "credit-card-lending-api"
    },
    {
        redis_database_name       = "back-office-dmz-uat"
        kubernetes_namespace_name = "pi-cc-lending-dmz-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-dmz"
        service_name              = "back-office"
    },
    {
        redis_database_name       = "credit-card-lending-api-dmz-uat"
        kubernetes_namespace_name = "pi-cc-lending-dmz-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-dmz"
        service_name              = "credit-card-lending-api"
    },
# DEV environment
    {
        redis_database_name       = "unistatement-internal-enrichment-dev"
        kubernetes_namespace_name = "accounting-dev"
        environment               = "dev"
        domain_name               = "accounting"
        service_name              = "unistatement-internal-enrichment"
    },
    {
        redis_database_name       = "unistatement-internal-enrichment-uat"
        kubernetes_namespace_name = "accounting-uat"
        environment               = "uat"
        domain_name               = "accounting"
        service_name              = "unistatement-internal-enrichment"
    },
    {
        redis_database_name       = "boot-admin-dev"
        kubernetes_namespace_name = "accounts-secsettlementcustody-dev"
        environment               = "dev"
        domain_name               = "accounts-secsettlementcustody"
        service_name              = "boot-admin"
    },
    {
        redis_database_name       = "ies-custody-dev"
        kubernetes_namespace_name = "accounts-secsettlementcustody-dev"
        environment               = "dev"
        domain_name               = "accounts-secsettlementcustody"
        service_name              = "ies-custody"
    },
    {
        redis_database_name       = "boot-admin-uat"
        kubernetes_namespace_name = "accounts-secsettlementcustody-uat"
        environment               = "uat"
        domain_name               = "accounts-secsettlementcustody"
        service_name              = "boot-admin"
    },
    {
        redis_database_name       = "ies-custody-uat"
        kubernetes_namespace_name = "accounts-secsettlementcustody-uat"
        environment               = "uat"
        domain_name               = "accounts-secsettlementcustody"
        service_name              = "ies-custody"
    },
    {
        redis_database_name       = "auth-dev"
        kubernetes_namespace_name = "cards-dev"
        environment               = "dev"
        domain_name               = "cards"
        service_name              = "auth"
    },
    {
        redis_database_name       = "card-account-balance-dev"
        kubernetes_namespace_name = "cards-dev"
        environment               = "dev"
        domain_name               = "cards"
        service_name              = "card-account-balance"
    },
    {
        redis_database_name       = "card-dev"
        kubernetes_namespace_name = "cards-dev"
        environment               = "dev"
        domain_name               = "cards"
        service_name              = "card"
    },
    {
        redis_database_name       = "payment-dev"
        kubernetes_namespace_name = "cards-dev"
        environment               = "dev"
        domain_name               = "cards"
        service_name              = "payment"
    },
    {
        redis_database_name       = "rpc-merchant-adapter-dev"
        kubernetes_namespace_name = "cards-dev"
        environment               = "dev"
        domain_name               = "cards"
        service_name              = "rpc-merchant-adapter"
    },
    {
        redis_database_name       = "auth-uat"
        kubernetes_namespace_name = "cards-uat"
        environment               = "uat"
        domain_name               = "cards"
        service_name              = "auth"
    },
    {
        redis_database_name       = "card-account-balance-uat"
        kubernetes_namespace_name = "cards-uat"
        environment               = "uat"
        domain_name               = "cards"
        service_name              = "card-account-balance"
    },
    {
        redis_database_name       = "card-uat"
        kubernetes_namespace_name = "cards-uat"
        environment               = "uat"
        domain_name               = "cards"
        service_name              = "card"
    },
    {
        redis_database_name       = "payment-uat"
        kubernetes_namespace_name = "cards-uat"
        environment               = "uat"
        domain_name               = "cards"
        service_name              = "payment"
    },
    {
        redis_database_name       = "rpc-merchant-adapter-uat"
        kubernetes_namespace_name = "cards-uat"
        environment               = "uat"
        domain_name               = "cards"
        service_name              = "rpc-merchant-adapter"
    },
    {
        redis_database_name       = "backend-for-frontend-myraif-dev"
        kubernetes_namespace_name = "channel-mobile-dev"
        environment               = "dev"
        domain_name               = "channel-mobile"
        service_name              = "backend-for-frontend-myraif"
    },
    {
        redis_database_name       = "myraif-bff-auth-dev"
        kubernetes_namespace_name = "channel-mobile-dev"
        environment               = "dev"
        domain_name               = "channel-mobile"
        service_name              = "myraif-bff-auth"
    },
    {
        redis_database_name       = "backend-for-frontend-myraif-uat"
        kubernetes_namespace_name = "channel-mobile-uat"
        environment               = "uat"
        domain_name               = "channel-mobile"
        service_name              = "backend-for-frontend-myraif"
    },
    {
        redis_database_name       = "myraif-bff-auth-uat"
        kubernetes_namespace_name = "channel-mobile-uat"
        environment               = "uat"
        domain_name               = "channel-mobile"
        service_name              = "myraif-bff-auth"
    },
    {
        redis_database_name       = "chat-bot-dev"
        kubernetes_namespace_name = "channels-chatbot-lan-dev"
        environment               = "dev"
        domain_name               = "channels-chatbot-lan"
        service_name              = "chat-bot"
    },
    {
        redis_database_name       = "chat-bot-uat"
        kubernetes_namespace_name = "channels-chatbot-lan-uat"
        environment               = "uat"
        domain_name               = "channels-chatbot-lan"
        service_name              = "chat-bot"
    },
    {
        redis_database_name       = "kafka-adapter-dev"
        kubernetes_namespace_name = "channels-dev"
        environment               = "dev"
        domain_name               = "channels"
        service_name              = "kafka-adapter"
    },
    {
        redis_database_name       = "rgo-auth-dev"
        kubernetes_namespace_name = "channels-dev"
        environment               = "dev"
        domain_name               = "channels"
        service_name              = "rgo-auth"
    },
    {
        redis_database_name       = "rgo-client-editing-dev"
        kubernetes_namespace_name = "channels-dev"
        environment               = "dev"
        domain_name               = "channels"
        service_name              = "rgo-client-editing"
    },
    {
        redis_database_name       = "kafka-adapter-uat"
        kubernetes_namespace_name = "channels-uat"
        environment               = "uat"
        domain_name               = "channels"
        service_name              = "kafka-adapter"
    },
    {
        redis_database_name       = "rgo-auth-uat"
        kubernetes_namespace_name = "channels-uat"
        environment               = "uat"
        domain_name               = "channels"
        service_name              = "rgo-auth"
    },
    {
        redis_database_name       = "rgo-client-editing-uat"
        kubernetes_namespace_name = "channels-uat"
        environment               = "uat"
        domain_name               = "channels"
        service_name              = "rgo-client-editing"
    },
    {
        redis_database_name       = "channels-web-gateway-dev"
        kubernetes_namespace_name = "channels-web-dev"
        environment               = "dev"
        domain_name               = "channels-web"
        service_name              = "channels-web-gateway"
    },
    {
        redis_database_name       = "ufo-auth-dev"
        kubernetes_namespace_name = "channels-web-dev"
        environment               = "dev"
        domain_name               = "channels-web"
        service_name              = "ufo-auth"
    },
    {
        redis_database_name       = "channels-web-gateway-uat"
        kubernetes_namespace_name = "channels-web-uat"
        environment               = "uat"
        domain_name               = "channels-web"
        service_name              = "channels-web-gateway"
    },
    {
        redis_database_name       = "ufo-auth-uat"
        kubernetes_namespace_name = "channels-web-uat"
        environment               = "uat"
        domain_name               = "channels-web"
        service_name              = "ufo-auth"
    },
    {
        redis_database_name       = "sfincs-dev"
        kubernetes_namespace_name = "clients-compliance-dev"
        environment               = "dev"
        domain_name               = "clients-compliance"
        service_name              = "sfincs"
    },
    {
        redis_database_name       = "sfincs-uat"
        kubernetes_namespace_name = "clients-compliance-uat"
        environment               = "uat"
        domain_name               = "clients-compliance"
        service_name              = "sfincs"
    },
    {
        redis_database_name       = "client-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "client"
    },
    {
        redis_database_name       = "cmd-clients-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "cmd-clients"
    },
    {
        redis_database_name       = "dictionaries-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "dictionaries"
    },
    {
        redis_database_name       = "digital-onboarding-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "digital-onboarding"
    },
    {
        redis_database_name       = "diia-gateway-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "diia-gateway"
    },
    {
        redis_database_name       = "diia-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "diia"
    },
    {
        redis_database_name       = "onboarding-backend-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "onboarding-backend"
    },
    {
        redis_database_name       = "ro-onboarding-adapter-dev"
        kubernetes_namespace_name = "clients-dev"
        environment               = "dev"
        domain_name               = "clients"
        service_name              = "ro-onboarding-adapter"
    },
    {
        redis_database_name       = "documents-gateway-dev"
        kubernetes_namespace_name = "clients-document-dev"
        environment               = "dev"
        domain_name               = "clients-document"
        service_name              = "documents-gateway"
    },
    {
        redis_database_name       = "documents-gateway-uat"
        kubernetes_namespace_name = "clients-document-uat"
        environment               = "uat"
        domain_name               = "clients-document"
        service_name              = "documents-gateway"
    },
    {
        redis_database_name       = "client-identification-gateway-dev"
        kubernetes_namespace_name = "clients-identification-dev"
        environment               = "dev"
        domain_name               = "clients-identification"
        service_name              = "client-identification-gateway"
    },
    {
        redis_database_name       = "newcontractors-publisher-dev"
        kubernetes_namespace_name = "clients-identification-dev"
        environment               = "dev"
        domain_name               = "clients-identification"
        service_name              = "newcontractors-publisher"
    },
    {
        redis_database_name       = "client-identification-gateway-uat"
        kubernetes_namespace_name = "clients-identification-uat"
        environment               = "uat"
        domain_name               = "clients-identification"
        service_name              = "client-identification-gateway"
    },
    {
        redis_database_name       = "newcontractors-publisher-uat"
        kubernetes_namespace_name = "clients-identification-uat"
        environment               = "uat"
        domain_name               = "clients-identification"
        service_name              = "newcontractors-publisher"
    },
    {
        redis_database_name       = "clients-loyalty-dev"
        kubernetes_namespace_name = "clients-loyalty-dev"
        environment               = "dev"
        domain_name               = "clients-loyalty"
        service_name              = "clients-loyalty"
    },
    {
        redis_database_name       = "loyalty-gateway-dev"
        kubernetes_namespace_name = "clients-loyalty-dev"
        environment               = "dev"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-gateway"
    },
    {
        redis_database_name       = "loyalty-limbo-dev"
        kubernetes_namespace_name = "clients-loyalty-dev"
        environment               = "dev"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-limbo"
    },
    {
        redis_database_name       = "loyalty-transaction-history-dev"
        kubernetes_namespace_name = "clients-loyalty-dev"
        environment               = "dev"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-transaction-history"
    },
    {
        redis_database_name       = "loyalty-transactions-splitter-dev"
        kubernetes_namespace_name = "clients-loyalty-dev"
        environment               = "dev"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-transactions-splitter"
    },
    {
        redis_database_name       = "clients-loyalty-uat"
        kubernetes_namespace_name = "clients-loyalty-uat"
        environment               = "uat"
        domain_name               = "clients-loyalty"
        service_name              = "clients-loyalty"
    },
    {
        redis_database_name       = "loyalty-gateway-uat"
        kubernetes_namespace_name = "clients-loyalty-uat"
        environment               = "uat"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-gateway"
    },
    {
        redis_database_name       = "loyalty-limbo-uat"
        kubernetes_namespace_name = "clients-loyalty-uat"
        environment               = "uat"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-limbo"
    },
    {
        redis_database_name       = "loyalty-transaction-history-uat"
        kubernetes_namespace_name = "clients-loyalty-uat"
        environment               = "uat"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-transaction-history"
    },
    {
        redis_database_name       = "loyalty-transactions-splitter-uat"
        kubernetes_namespace_name = "clients-loyalty-uat"
        environment               = "uat"
        domain_name               = "clients-loyalty"
        service_name              = "loyalty-transactions-splitter"
    },
    {
        redis_database_name       = "client-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "client"
    },
    {
        redis_database_name       = "cmd-clients-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "cmd-clients"
    },
    {
        redis_database_name       = "dictionaries-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "dictionaries"
    },
    {
        redis_database_name       = "digital-onboarding-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "digital-onboarding"
    },
    {
        redis_database_name       = "diia-gateway-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "diia-gateway"
    },
    {
        redis_database_name       = "diia-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "diia"
    },
    {
        redis_database_name       = "onboarding-backend-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "onboarding-backend"
    },
    {
        redis_database_name       = "ro-onboarding-adapter-uat"
        kubernetes_namespace_name = "clients-uat"
        environment               = "uat"
        domain_name               = "clients"
        service_name              = "ro-onboarding-adapter"
    },
    {
        redis_database_name       = "bmrs-account-maintenance-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "bmrs-account-maintenance"
    },
    {
        redis_database_name       = "bmrs-loan-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "bmrs-loan"
    },
    {
        redis_database_name       = "bmrs-payment-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "bmrs-payment"
    },
    {
        redis_database_name       = "bmrs-rate-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "bmrs-rate"
    },
    {
        redis_database_name       = "limits-and-facilities-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "limits-and-facilities"
    },
    {
        redis_database_name       = "loan579-entry-dev"
        kubernetes_namespace_name = "core-banking-dev"
        environment               = "dev"
        domain_name               = "core-banking"
        service_name              = "loan579-entry"
    },
    {
        redis_database_name       = "bmrs-account-maintenance-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "bmrs-account-maintenance"
    },
    {
        redis_database_name       = "bmrs-loan-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "bmrs-loan"
    },
    {
        redis_database_name       = "bmrs-payment-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "bmrs-payment"
    },
    {
        redis_database_name       = "bmrs-rate-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "bmrs-rate"
    },
    {
        redis_database_name       = "limits-and-facilities-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "limits-and-facilities"
    },
    {
        redis_database_name       = "loan579-entry-uat"
        kubernetes_namespace_name = "core-banking-uat"
        environment               = "uat"
        domain_name               = "core-banking"
        service_name              = "loan579-entry"
    },
    {
        redis_database_name       = "fx-rates-dev"
        kubernetes_namespace_name = "foreign-exchange-dev"
        environment               = "dev"
        domain_name               = "foreign-exchange"
        service_name              = "fx-rates"
    },
    {
        redis_database_name       = "fx-trades-integral-dev"
        kubernetes_namespace_name = "foreign-exchange-dev"
        environment               = "dev"
        domain_name               = "foreign-exchange"
        service_name              = "fx-trades-integral"
    },
    {
        redis_database_name       = "fx-trades-dev"
        kubernetes_namespace_name = "foreign-exchange-dev"
        environment               = "dev"
        domain_name               = "foreign-exchange"
        service_name              = "fx-trades"
    },
    {
        redis_database_name       = "fx-rates-uat"
        kubernetes_namespace_name = "foreign-exchange-uat"
        environment               = "uat"
        domain_name               = "foreign-exchange"
        service_name              = "fx-rates"
    },
    {
        redis_database_name       = "fx-trades-integral-uat"
        kubernetes_namespace_name = "foreign-exchange-uat"
        environment               = "uat"
        domain_name               = "foreign-exchange"
        service_name              = "fx-trades-integral"
    },
    {
        redis_database_name       = "fx-trades-uat"
        kubernetes_namespace_name = "foreign-exchange-uat"
        environment               = "uat"
        domain_name               = "foreign-exchange"
        service_name              = "fx-trades"
    },
    {
        redis_database_name       = "lending-checking-dev"
        kubernetes_namespace_name = "loans-dev"
        environment               = "dev"
        domain_name               = "loans"
        service_name              = "lending-checking"
    },
    {
        redis_database_name       = "repayment-schedules-api-gateway-dev"
        kubernetes_namespace_name = "loans-dev"
        environment               = "dev"
        domain_name               = "loans"
        service_name              = "repayment-schedules-api-gateway"
    },
    {
        redis_database_name       = "repayment-schedules-dev"
        kubernetes_namespace_name = "loans-dev"
        environment               = "dev"
        domain_name               = "loans"
        service_name              = "repayment-schedules"
    },
    {
        redis_database_name       = "factoring-outgoing-payments-uat"
        kubernetes_namespace_name = "loans-tf-uat"
        environment               = "uat"
        domain_name               = "loans-tf"
        service_name              = "factoring-outgoing-payments"
    },
    {
        redis_database_name       = "lending-checking-uat"
        kubernetes_namespace_name = "loans-uat"
        environment               = "uat"
        domain_name               = "loans"
        service_name              = "lending-checking"
    },
    {
        redis_database_name       = "repayment-schedules-api-gateway-uat"
        kubernetes_namespace_name = "loans-uat"
        environment               = "uat"
        domain_name               = "loans"
        service_name              = "repayment-schedules-api-gateway"
    },
    {
        redis_database_name       = "repayment-schedules-uat"
        kubernetes_namespace_name = "loans-uat"
        environment               = "uat"
        domain_name               = "loans"
        service_name              = "repayment-schedules"
    },
    {
        redis_database_name       = "account-dev"
        kubernetes_namespace_name = "payments-dev"
        environment               = "dev"
        domain_name               = "payments"
        service_name              = "account"
    },
    {
        redis_database_name       = "payment-engine-execution-dev"
        kubernetes_namespace_name = "payments-dev"
        environment               = "dev"
        domain_name               = "payments"
        service_name              = "payment-engine-execution"
    },
    {
        redis_database_name       = "payment-preprocessing-dev"
        kubernetes_namespace_name = "payments-dev"
        environment               = "dev"
        domain_name               = "payments"
        service_name              = "payment-preprocessing"
    },
    {
        redis_database_name       = "payment-signatures-dev"
        kubernetes_namespace_name = "payments-dev"
        environment               = "dev"
        domain_name               = "payments"
        service_name              = "payment-signatures"
    },
    {
        redis_database_name       = "payment-transmaster-connector-dev"
        kubernetes_namespace_name = "payments-dev"
        environment               = "dev"
        domain_name               = "payments"
        service_name              = "payment-transmaster-connector"
    },
    {
        redis_database_name       = "dd-requirement-dev"
        kubernetes_namespace_name = "payments-direct-debit-dev"
        environment               = "dev"
        domain_name               = "payments-direct-debit"
        service_name              = "dd-requirement"
    },
    {
        redis_database_name       = "dd-subscription-dev"
        kubernetes_namespace_name = "payments-direct-debit-dev"
        environment               = "dev"
        domain_name               = "payments-direct-debit"
        service_name              = "dd-subscription"
    },
    {
        redis_database_name       = "dd-requirement-uat"
        kubernetes_namespace_name = "payments-direct-debit-uat"
        environment               = "uat"
        domain_name               = "payments-direct-debit"
        service_name              = "dd-requirement"
    },
    {
        redis_database_name       = "dd-subscription-uat"
        kubernetes_namespace_name = "payments-direct-debit-uat"
        environment               = "uat"
        domain_name               = "payments-direct-debit"
        service_name              = "dd-subscription"
    },
    {
        redis_database_name       = "credential-auth-dev"
        kubernetes_namespace_name = "payments-fxss-dev"
        environment               = "dev"
        domain_name               = "payments-fxss"
        service_name              = "credential-auth"
    },
    {
        redis_database_name       = "gateway-fxss-dev"
        kubernetes_namespace_name = "payments-fxss-dev"
        environment               = "dev"
        domain_name               = "payments-fxss"
        service_name              = "gateway-fxss"
    },
    {
        redis_database_name       = "kerberos-auth-dev"
        kubernetes_namespace_name = "payments-fxss-dev"
        environment               = "dev"
        domain_name               = "payments-fxss"
        service_name              = "kerberos-auth"
    },
    {
        redis_database_name       = "manager-akd-dev"
        kubernetes_namespace_name = "payments-fxss-dev"
        environment               = "dev"
        domain_name               = "payments-fxss"
        service_name              = "manager-akd"
    },
    {
        redis_database_name       = "credential-auth-uat"
        kubernetes_namespace_name = "payments-fxss-uat"
        environment               = "uat"
        domain_name               = "payments-fxss"
        service_name              = "credential-auth"
    },
    {
        redis_database_name       = "gateway-fxss-uat"
        kubernetes_namespace_name = "payments-fxss-uat"
        environment               = "uat"
        domain_name               = "payments-fxss"
        service_name              = "gateway-fxss"
    },
    {
        redis_database_name       = "kerberos-auth-uat"
        kubernetes_namespace_name = "payments-fxss-uat"
        environment               = "uat"
        domain_name               = "payments-fxss"
        service_name              = "kerberos-auth"
    },
    {
        redis_database_name       = "manager-akd-uat"
        kubernetes_namespace_name = "payments-fxss-uat"
        environment               = "uat"
        domain_name               = "payments-fxss"
        service_name              = "manager-akd"
    },
    {
        redis_database_name       = "salary-contract-dev"
        kubernetes_namespace_name = "payments-salary-dev"
        environment               = "dev"
        domain_name               = "payments-salary"
        service_name              = "salary-contract"
    },
    {
        redis_database_name       = "salary-import-dev"
        kubernetes_namespace_name = "payments-salary-dev"
        environment               = "dev"
        domain_name               = "payments-salary"
        service_name              = "salary-import"
    },
    {
        redis_database_name       = "salary-payroll-dev"
        kubernetes_namespace_name = "payments-salary-dev"
        environment               = "dev"
        domain_name               = "payments-salary"
        service_name              = "salary-payroll"
    },
    {
        redis_database_name       = "salary-permission-dev"
        kubernetes_namespace_name = "payments-salary-dev"
        environment               = "dev"
        domain_name               = "payments-salary"
        service_name              = "salary-permission"
    },
    {
        redis_database_name       = "salary-rgo-bff-dev"
        kubernetes_namespace_name = "payments-salary-dev"
        environment               = "dev"
        domain_name               = "payments-salary"
        service_name              = "salary-rgo-bff"
    },
    {
        redis_database_name       = "salary-contract-uat"
        kubernetes_namespace_name = "payments-salary-uat"
        environment               = "uat"
        domain_name               = "payments-salary"
        service_name              = "salary-contract"
    },
    {
        redis_database_name       = "salary-import-uat"
        kubernetes_namespace_name = "payments-salary-uat"
        environment               = "uat"
        domain_name               = "payments-salary"
        service_name              = "salary-import"
    },
    {
        redis_database_name       = "salary-payroll-uat"
        kubernetes_namespace_name = "payments-salary-uat"
        environment               = "uat"
        domain_name               = "payments-salary"
        service_name              = "salary-payroll"
    },
    {
        redis_database_name       = "salary-permission-uat"
        kubernetes_namespace_name = "payments-salary-uat"
        environment               = "uat"
        domain_name               = "payments-salary"
        service_name              = "salary-permission"
    },
    {
        redis_database_name       = "salary-rgo-bff-uat"
        kubernetes_namespace_name = "payments-salary-uat"
        environment               = "uat"
        domain_name               = "payments-salary"
        service_name              = "salary-rgo-bff"
    },
    {
        redis_database_name       = "account-uat"
        kubernetes_namespace_name = "payments-uat"
        environment               = "uat"
        domain_name               = "payments"
        service_name              = "account"
    },
    {
        redis_database_name       = "payment-engine-execution-uat"
        kubernetes_namespace_name = "payments-uat"
        environment               = "uat"
        domain_name               = "payments"
        service_name              = "payment-engine-execution"
    },
    {
        redis_database_name       = "payment-preprocessing-uat"
        kubernetes_namespace_name = "payments-uat"
        environment               = "uat"
        domain_name               = "payments"
        service_name              = "payment-preprocessing"
    },
    {
        redis_database_name       = "payment-signatures-uat"
        kubernetes_namespace_name = "payments-uat"
        environment               = "uat"
        domain_name               = "payments"
        service_name              = "payment-signatures"
    },
    {
        redis_database_name       = "payment-transmaster-connector-uat"
        kubernetes_namespace_name = "payments-uat"
        environment               = "uat"
        domain_name               = "payments"
        service_name              = "payment-transmaster-connector"
    },
    {
        redis_database_name       = "credit-card-agreement-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-agreement"
    },
    {
        redis_database_name       = "credit-card-document-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-document"
    },
    {
        redis_database_name       = "credit-card-lending-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-lending"
    },
    {
        redis_database_name       = "customer-data-collector-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "customer-data-collector"
    },
    {
        redis_database_name       = "loan-decision-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "loan-decision"
    },
    {
        redis_database_name       = "robotics-gateway-dev"
        kubernetes_namespace_name = "pi-cc-lending-lan-dev"
        environment               = "dev"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "robotics-gateway"
    },
    {
        redis_database_name       = "credit-card-agreement-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-agreement"
    },
    {
        redis_database_name       = "credit-card-document-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-document"
    },
    {
        redis_database_name       = "credit-card-lending-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "credit-card-lending"
    },
    {
        redis_database_name       = "customer-data-collector-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "customer-data-collector"
    },
    {
        redis_database_name       = "loan-decision-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "loan-decision"
    },
    {
        redis_database_name       = "robotics-gateway-uat"
        kubernetes_namespace_name = "pi-cc-lending-lan-uat"
        environment               = "uat"
        domain_name               = "pi-cc-lending-lan"
        service_name              = "robotics-gateway"
    },
    {
        redis_database_name       = "rice-api-gateway-dev"
        kubernetes_namespace_name = "rice-dev"
        environment               = "dev"
        domain_name               = "rice"
        service_name              = "rice-api-gateway"
    },
    {
        redis_database_name       = "rice-api-gateway-uat"
        kubernetes_namespace_name = "rice-uat"
        environment               = "uat"
        domain_name               = "rice"
        service_name              = "rice-api-gateway"
    },
    {
        redis_database_name       = "agreement-signers-uat"
        kubernetes_namespace_name = "sign-lan-uat"
        environment               = "uat"
        domain_name               = "sign-lan"
        service_name              = "agreement-signers"
    },
    {
        redis_database_name       = "arrest-dev"
        kubernetes_namespace_name = "sova-dev"
        environment               = "dev"
        domain_name               = "sova"
        service_name              = "arrest"
    },
    {
        redis_database_name       = "arrest-uat"
        kubernetes_namespace_name = "sova-uat"
        environment               = "uat"
        domain_name               = "sova"
        service_name              = "arrest"
    }
  ]
}
