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
      from_port   = 22
      description = "Allow ssh traffic"
      protocol    = "tcp"
      cidr_blocks = [aws_subnet.fleur-public-subnet[0].cidr_block, "71.163.242.34/32"]
    },
    {
      description = "Allow sonarqube traffic traffic"
      from_port   = 9000
      to_port     = 9000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    },
    {
      description = "Allow  http traffic traffic"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

    },
    {
      description = "Allow  https traffic traffic"
      from_port   = 8000
      to_port     = 8000
      protocol    = "tcp"
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

  private = [
    {
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
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]

  egree_rule = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]

  common_secret_values = {
    engine     = var.db_clusters.engine
    port       = var.db_clusters.port
    dbname     = var.db_clusters.dbname
    identifier = var.db_clusters.identifier
    password   = random_string.master_user_password.result
  }
  common_tenable_values = {
    engine   = local.engines_map[var.db_clusters.engine]
    endpoint = aws_db_instance.postgres_rds.address
    port     = var.db_clusters.port
    dbname   = var.db_clusters.dbname
    password = random_string.master_user_password.result
  }
  engines_map = {
    aurora-postgresql = "postgres"
    postgres          = "postgres"
    redshift          = "redshift"
  }
  default_tags = {
    Name                    = "hqr-bellese"
    Created_by              = "devops@hqr.io"
    App_Name                = "ovid"
    Cost_center             = "xyz222"
    Business_unit           = "GBS"
    App_role                = "web_server"
    Environment             = "dev"
    Security_Classification = "Internal"
  }
}
