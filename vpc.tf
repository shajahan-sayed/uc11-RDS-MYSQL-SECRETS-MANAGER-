resource "aws_vpc" "two_tier" {
  cidr = var.vpc_cidr

  tags = {
    Name = "two-tier"
  }
}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.two_tier.id
  cidr = var.public1_cidr
  availability_zone = "var.availability_zone1"

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.two_tier.id
  cidr = var.public2_cidr
  availability_zone = "var.availability_zone2"

  tags = {
    Name = "public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.two_tier.id
  cidr = var.private1_cidr
  availability_zone = "var.availability_zone1"

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.two_tier.id
  cidr = var.private2_cidr
  availability_zone = "var.availability_zone2"

  tags = {
    Name = "private2"
  }
}

#creating IGW
resource "aws_internet_gateway" "igw_two" {
  vpc_id = aws_vpc_id.two_tier.id

  tags = {
    Name = "igw_two"
  }
}

#creating route table
resource "aws_route_table" "route_two" {
   vpc_id = aws_vpc.two_tier.id

   tags = { 
      Name = "route_two"
    }
  }
#creating route 
resource "aws_route" "two_route" {
   vpc_id = aws_vpc.two_tier.id
   destination_cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway_id.igw_two.id
}

#creating route table association 
resource "aws_route_table_association" "public1_two" {
  route_table_id = aws_subnet.public1.id
  gateway_id = aws_internet_gateway_id.igw_two.id

}
resource "aws_route_table_association" "public2_two" {
  route_table_id = aws_subnet_id.public2.id
  gateway_id  = aws_internet_gateway_id.igw_two.id
}

#creating eip to attach to nat gateway so nat can access internet for updates
  resource "aws_eip" "eip_two" {
    domain = "vpc"
  }

#creating nat gateway
  resource "aws_nat_gateway_id" "nat_two" {
    subnet_id = aws_subnet.public1.id
    allocation_id = aws_eip.eip_two.id

    depends_on = [aws_internet_gateway.igw] # Ensures IGW is ready before NAT

    tags = {
      Name = "nat_two"
    }
  }
#creating routetable for private subnet
  resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc_id.two_tier.id

    tags = {
      Name = "private_route"
    }
  }

  resource "aws_route" "route_private" {
    gateway_id = aws_nat_gateway.nat_two.id
    vpc_id = aws_vpc.two_tier.id
    destination_cidr_block = "0.0.0.0/0"

  }

  resource "aws_route_table_association" "private1_subnet_association" {
    gateway_id = aws_nat_gateway.nat_two.id
    subnet_id = aws_subnet.private1.id
  }

   resource "aws_route_table_association" "private2_subnet_association" {
    gateway_id = aws_nat_gateway.nat_two.id
    subnet_id = aws_subnet.private2.id
  }

  #creating security group for EC2 

  resource "aws_security_group" "two_ec2_sg" {
    vpc_id = aws_vpc_id.two_tier.id

    ingress {
      from_port = 22
      to_port =22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"] # Change to your IP for security
    }

   ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
     Name = "two-ec2-sg" 
   }
 }

#creating sg group for rds (to allow mysql from ec2)
  resource "aws_security_group" "rds_two" {
   vpc_id = aws_vpc_id.two_tier.id
   ingress {
    description     = "Allow MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.ec2_sg.id] # Only allow EC2
   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { 
    Name = "rds_two"
  }
}
    
    
  
    
    

    
  
    
    

  

  
  
