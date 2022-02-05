terraform {
  cloud {
    organization = "hqr-blesses"

    workspaces {
      name = "hqr-operational-enviroment"
    }
  }
}
