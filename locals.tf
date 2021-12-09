# public security group

locals {
  ingress_rules = [{
    to_port     = 8080
    description = "port 443"
    protocol    = "tcp"
    from_port   = 8080
    cidr_blocks = ["69.140.69.104/32", "71.163.242.34/32"]
    },
    {
      to_port     = 22
      description = "port 22"
      from_port   = 22
      protocol    = "tcp"
      cidr_blocks = ["69.140.69.104/32", "71.163.242.34/32"]
    },
    {
      to_port     = 80
      from_port   = 80
      description = "port 443"
      protocol    = "tcp"
      cidr_blocks = ["69.140.69.104/32", "71.163.242.34/32"]
    },
    {
      description = "Allow HTTP traffic"
      from_port   = 9000
      protocol    = "tcp"
      to_port     = 9000
      cidr_blocks = ["69.140.69.104/32", "71.163.242.34/32"]
  }]

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
      cidr_blocks = [var.fleur-cidr-block]
  }]

  egree_rule = [{
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }]

}


# privide securty group