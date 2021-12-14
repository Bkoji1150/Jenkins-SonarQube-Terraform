# public security group

locals {
  ingress_rules = [{
    to_port     = 8080
    description = "Allow jenkins port"
    protocol    = "tcp"
    from_port   = 8080
    cidr_blocks = ["0.0.0.0/0"]
    },
    {
      to_port     = 22
      description = "Allow ssh traffic"
      from_port   = 22
      protocol    = "tcp"
      cidr_blocks = [aws_subnet.fleur-public-subnet[0].cidr_block, "71.163.242.34/32"]
    },
    {
      description = "Allow sonarqube traffic traffic"
      from_port   = 9000
      protocol    = "tcp"
      to_port     = 9000
      cidr_blocks = ["0.0.0.0/0"]

    },
    {
      description = "Allow internal trafic within pub subnet traffic"
      from_port   = 0
      protocol    = "-1"
      to_port     = 0
      cidr_blocks = [var.fleur-cidr-block]
    }
  ]

  private = [{
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.fleur-cidr-block]
    },
    { description = "Allow Postgres traffic"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      cidr_blocks = [var.fleur-cidr-block, "71.163.242.34/32"]
    }
  ]

  egree_rule = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]

  #  defaults_parameters = [
  #    {
  #      name = "log_connections"
  #      value = 1
  #      apply_method = "immediate"

  #  }]
  common_secret_values = {
    engine = var.db_clusters.engine
    # endpoint = aws_db_instance.postgres_rds.enpoint
    port       = var.db_clusters.port
    dbname     = var.db_clusters.dbname
    identifier = var.db_clusters.identifier
    password   = random_string.master_user_password.result
  }

}

locals {
  default_tags = {
    Name                    = "jjtechAPP"
    name                    = ""
    App_Name                = "ovid"
    Cost_center             = "xyz222"
    Business_unit           = "GBS"
    Business_unit           = "GBS"
    App_role                = "web_server"
    App_role                = "web_server"
    Environment             = "dev"
    Security_Classification = "NA"
  }
}

# privide securty group