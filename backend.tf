terraform {
  cloud {
    organization = "hqr-blesses"

    workspaces {
      name = "hqr_operational_enviroment"
    }
  }
}
