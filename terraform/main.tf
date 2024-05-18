# The configuration for the `remote` backend.
terraform {
  backend "remote" {
    # The name of your Terraform Cloud organization.
    organization = "Cloud-Platform"

    # The name of the Terraform Cloud workspace to store Terraform state files in.
    workspaces {
      name = "sam-aws-workspace"
    }
  }
}

# An example resource that does nothing.
# resource "null_resource" "example" {
#  triggers = {
#    value = "An example resource that does nothing!!"
#  }
# }


resource "aws_iam_user" "tflock" {
    name = "testing"
}


provider "aws" {
  region = "eu-west-1"
}

resource "aws_vpc" "my_vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    terraform = "true"
    Name      = "my vpc"
  }
}

resource "aws_subnet" "public_sn" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "eu-west-1a"

  tags = {
    Name = "Public subnet"
  }
}

resource "aws_key_pair" "server-demo-key" {
  key_name   = "demo-key"
  public_key = "MIIEpAIBAAKCAQEAuFuigAit3PgQxAfbTePhRWwlz24CMYXkdFJpu+b+M5ehQgXQ
DJeXb9JqHGtookytNiZRGqQ+nY6CG6gq3Gf5zne+AZVl45Lr5U8wCwoiuEayehk4
DO25UlATgTLAFzSaX4w9PtfvgitQNleNXWUHAIPj0FXak6GgHxdd9PyIzWhqCGfc
ND1fRdFq+2MBADMR0f0JHOrOYKCoq/l3YU47Tfq/WnprUJtWf+LpOJ5p7jbhWuWv
SA9FUnOCYuVK71pm9tFj4EyF920vVlmfeKA6iot7v+WxGhMXHqnCOrZ0I/yAoMUM
Jc1wKyf7XJoA8rkin0En4NAgcRrsxYA2MdE5wQIDAQABAoIBAQCjwhHYNN1rWJZb
6rasu2zQ4726QXeFUe+aO9Jb7FWEsn21TcB+TvFfjMJguC/basy5OtP0HEzaW0nL
E1fvLBTDh62pbnFw8oLDz9FXHQu2MGY8+sXFBi0FpseMje3/LuSpVsLYXasMLzky
7BZQDXtow77KwlhDpt+6fmEhSmiiO0ju9ucE8DQa/4tt0VrJHWG1nRpHo5odhR/s
S+Voi1dU2wuNe5tcL6p0R9tOwMCmqJJLDLPFB5QROIa6FdhqpxyaMl+dMNWwknY2
/pt2jhcicF4jHwjnifJq364ykkqfA8Kj1Pszemr1faoX1mkkg/4KJFBbQIQ3Qv3T
jK80YsCZAoGBAOS3s+Hvxecy6b6iIhKlLvIvn00dVJM98cegSjwWE8uCqkjLLQRz
LliN+53/VFxbk1ySVOYaJtqV4xzTYXo0rvjVa5fVrv/MwYFb/e7K7wL0U11h+vvU
w4bZneXVCB5sbr4QCLrZxEX5Famh6U6OP57QZT1f4Ddx1vG1bat6ZqAvAoGBAM5Z
VO/8lCL3gnl6+sLGCNoK8g5VzlqU+q/SYo6Ss/oqzSrklWvljEYA81qRkNbBXKbv
x1jm3RfAPyFBQNaTZISvKYHY/b9vNd/FBVZmbV9xqzfQPVjZVETmjQxG3FZBrf7m
2/d6pJTsyh8vkQnxqHF6d9oBgmd9X6m7Vn1g2tkPAoGAQ/OsNvE03AbNWXz0IJQB
CaVKb+/J4+Egh03BIG7yvKD6lJwAqPTLjTXJztxAJRx0AKndHWwhpQmpKzRGHreu
UHGgAMFUt90OlK9PF3YlYrxSVEk69zz0Rok7F0Ceo+NVV5SN822lmaByZi6bkWJD
1pxVp9FnXTGuSau8hJjeCrMCgYEAtBFUg5AgHVtr6mKdDPcPpmbC0CukxXsYP/IR
u2Td1cMgAvwyQFOyUyxlMHWytRVLqwm3JidgbGeBL53n3NgGcZsBV6Rp2nJLyxf9
DmaXryBcT3pS7oPIe8/M6he0EzmBgt0muxG1KZhw0UILCWhum4hJql6C05iesFkg
ooywrZUCgYBHSgE1oiOT5+CD7Df+uaFY6mZtQN0MxaE4PGmW1grMYjmX2Ye8lXP3
0YHexLaxgemJCKx8iPyRAI4CSwn9Ebh8dScls+fiNV4x5cA+vFUliQVshRuAVmXX
J6tBdsZSEtZySdh91WlZcFYn4ZzYHm9BAtL1x2zRqH1MZWR+xzvLWQ=="
}

resource "aws_instance" "test_server" {
  ami                         = "ami-09885f3ec1667cbfc"
  instance_type               = "t2.micro"
  subnet_id                   = aws_subnet.public_sn.id
  vpc_security_group_ids      = [aws_security_group.testserver-sg.id]
  key_name                    = aws_key_pair.server-demo-key.id
  associate_public_ip_address = true

  tags = {
    Name = "test server ec2"
  }
}

resource "aws_security_group" "testserver-sg" {
  name        = "test-sg"
  description = "allow inbound ssh and https traffic"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "internet gw"
  }
}

resource "aws_route_table" "public-rt" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }


  tags = {
    Name = "internet public route"
  }
}

resource "aws_route_table_association" "public-association-1" {
  subnet_id      = aws_subnet.public_sn.id
  route_table_id = aws_route_table.public-rt.id
}
