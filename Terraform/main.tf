resource "aws_vpc" "harper_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
}

resource "aws_subnet" "harper_subnet" {
  vpc_id     = aws_vpc.harper_vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-west-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "harper_igw" {
  vpc_id = aws_vpc.harper_vpc.id
}

resource "aws_route_table" "harper_route_table" {
  vpc_id = aws_vpc.harper_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.harper_igw.id
  }
}

resource "aws_route_table_association" "harper_route_table_association" {
  subnet_id      = aws_subnet.harper_subnet.id
  route_table_id = aws_route_table.harper_route_table.id
}

resource "aws_security_group" "harper_sg" {
  vpc_id = aws_vpc.harper_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2377
    to_port     = 2377
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 7946
    to_port     = 7946
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 4789
    to_port     = 4789
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }


  ingress {
    from_port   = 9105
    to_port     = 9105
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 9106
    to_port     = 9106
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = []
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "harper_instance" {
  count         = 3
  ami           = "ami-054a53dca63de757b"
  instance_type = "t2.medium"
  subnet_id     = aws_subnet.harper_subnet.id
  key_name      = "hurez@DESKTOP-G7B1SVC"

  private_ip = "10.0.1.${count.index + 10}"

  security_groups = [aws_security_group.harper_sg.id]

  root_block_device {
    volume_size = 10
  }

  tags = {
    Name = "Cluster-instance-${count.index + 1}"
  }
}

resource "aws_route53_zone" "harper_zone" {
  name = "alart.studio"
}

resource "aws_route53_record" "harper_dns_instances" {
  count   = 3
  zone_id = aws_route53_zone.harper_zone.zone_id
  name    = "instance-${count.index + 1}.alart.studio"
  type    = "A"
  ttl     = "300"

  records = [aws_instance.harper_instance[count.index].public_ip]
}