
data "aws_ami" "server_ami" {

  most_recent = true
  owners      = ["099720109477"]
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
  }
}

resource "random_id" "project-omega" {
  byte_length = 2
  count       = var.instance_count
  keepers = {
    key_name = var.keypair_name
  }
}

resource "aws_key_pair" "queens_key_auth" {
  key_name   = var.keypair_name
  public_key = file(var.public_key_path)
}

resource "aws_instance" "project-omega" {
  count         = var.instance_count
  instance_type = var.instance_type #"t3.micro"
  ami           = data.aws_ami.server_ami.id
  tags = {
    Name = "project-omega-${random_id.project-omega[count.index].dec}"
  }
  key_name               = aws_key_pair.queens_key_auth.id
  vpc_security_group_ids = var.public_sg
  subnet_id              = var.public_subnets[count.index]
  user_data = templatefile(var.user_data_path,
    {
      nodename    = "project-omega-${random_id.project-omega[count.index].dec}"
      db_endpoint = var.db_endpoint
      dbuser      = var.username
      dbpass      = var.password
      dbname      = var.name
    }
  )
  root_block_device {
    volume_size = var.vol_size # 10
  }

}

resource "aws_lb_target_group_attachment" "project-omega_attach" {
  count            = var.instance_count
  target_group_arn = var.lb_target_group_arn
  target_id        = aws_instance.project-omega[count.index].id
  port             = 8000
}

