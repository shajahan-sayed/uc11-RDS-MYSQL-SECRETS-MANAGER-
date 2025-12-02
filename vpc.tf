resource "aws_vpc" "two_tier" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "two-tier"
  }
}

resource "aws_subnet" "public1" {
  vpc_id = aws_vpc.two_tier.id
  cidr_block = var.public1_cidr
  availability_zone = "var.availability_zone11"

  tags = {
    Name = "public1"
  }
}

resource "aws_subnet" "public2" {
  vpc_id = aws_vpc.two_tier.id
  cidr_block = var.public2_cidr
  availability_zone = "var.availability_zone22"

  tags = {
    Name = "public2"
  }
}

resource "aws_subnet" "private1" {
  vpc_id = aws_vpc.two_tier.id
  cidr_block = var.private1_cidr
  availability_zone = "var.availability_zone11"

  tags = {
    Name = "private1"
  }
}

resource "aws_subnet" "private2" {
  vpc_id = aws_vpc.two_tier.id
  cidr_block = var.private2_cidr
  availability_zone = "var.availability_zone22"

  tags = {
    Name = "private2"
  }
}

#creating IGW
resource "aws_internet_gateway" "igw_two" {
  vpc_id = aws_vpc.two_tier.id

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
   route_table_id = aws_route_table.route_two.id
   destination_cidr_block = "0.0.0.0/0"
   gateway_id = aws_internet_gateway.igw_two.id
}

#creating route table association 
resource "aws_route_table_association" "public1_two" {
  route_table_id = aws_route_table.route_two.id
  subnet_id = aws_subnet.public1.id

}
resource "aws_route_table_association" "public2_two" {
  route_table_id = aws_route_table.route_two.id
  subnet_id = aws_subnet.public2.id
}

#creating eip to attach to nat gateway so nat can access internet for updates
  resource "aws_eip" "eip_two" {
    domain = "vpc"
  }

#creating nat gateway
  resource "aws_nat_gateway" "nat_two" {
    subnet_id = aws_subnet.public1.id
    allocation_id = aws_eip.eip_two.id

    depends_on = [aws_internet_gateway.igw_two] # Ensures IGW is ready before NAT

    tags = {
      Name = "nat_two"
    }
  }
#creating routetable for private subnet
  resource "aws_route_table" "private_route" {
    vpc_id = aws_vpc.two_tier.id

    tags = {
      Name = "private_route"
    }
  }

  resource "aws_route" "route_private" {
    nat_gateway_id = aws_nat_gateway.nat_two.id
    route_table_id = aws_route_table.private_route.id
    destination_cidr_block = "0.0.0.0/0"

  }

  resource "aws_route_table_association" "private1_subnet_association" {
    route_table_id = aws_route_table.private_route.id
    subnet_id = aws_subnet.private1.id
  }

   resource "aws_route_table_association" "private2_subnet_association" {
    route_table_id = aws_route_table.private_route.id
    subnet_id = aws_subnet.private2.id
  }

  #creating security group for EC2 

  resource "aws_security_group" "two_ec2_sg" {
    vpc_id = aws_vpc.two_tier.id

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
   vpc_id = aws_vpc.two_tier.id
   ingress {
    description     = "Allow MySQL from EC2"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.two_ec2_sg.id] # Only allow EC2
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
    
    
  
    
    

    
  
    
    

  

  
  
