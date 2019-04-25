provider "aws" {
    access_key = "${var.access_key}"
    secret_key = "${var.secret_key}"
    region = "${var.region}"
}

resource "aws_vpc" "vpc" {
    cidr_block = "${var.vpc_cidr}"
    enable_dns_hostnames = true
    tags {
        Name = "Demo-vpc"
    }
}

resource "aws_internet_gateway" "igw" {
    vpc_id = "${aws_vpc.vpc.id}"
}

resource "aws_eip" "natip" {
}

resource "aws_nat_gateway" "natgw" {
    allocation_id = "${aws_eip.natip.id}"
    subnet_id     = "${aws_subnet.Public-Sub.id}"

    tags = {
        Name = "NATGW"
    }
}

resource "aws_subnet" "Public-Sub" {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${var.Public_subnet_cidr}"
    availability_zone = "ap-southeast-1a"

    tags {
        Name = "PubSub"
    }
}

resource "aws_route_table" "Public-route" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_internet_gateway.igw.id}"
    }

    tags {
        Name = "Pub"
    }
}

resource "aws_route_table_association" "Public-Association" {
    subnet_id = "${aws_subnet.Public-Sub.id}"
    route_table_id = "${aws_route_table.Public-route.id}"
}

resource "aws_subnet" "Private-Sub" {
    vpc_id = "${aws_vpc.vpc.id}"

    cidr_block = "${var.Private_subnet_cidr}"
    availability_zone = "ap-southeast-1b"

    tags {
        Name = "Private"
    }
}

resource "aws_route_table" "private-route" {
    vpc_id = "${aws_vpc.vpc.id}"

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = "${aws_nat_gateway.natgw.id}"
    }

    tags {
        Name = "private"
    }
}

resource "aws_route_table_association" "private-Association" {
    subnet_id = "${aws_subnet.Private-Sub.id}"
    route_table_id = "${aws_route_table.private-route.id}"
}

resource "aws_security_group" "Public-SG" {
    name = "Application"
    description = "SG."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "PublicSG"
    }
}

resource "aws_security_group" "DB-SG" {
    name = "Private"
    description = "SG."

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["172.0.0.0/16"]
    }

    ingress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["172.0.0.0/16"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.vpc.id}"

    tags {
        Name = "DB"
    }
}

resource "aws_instance" "jump" {
    ami = "${var.amis}"
    count = 1
    availability_zone = "ap-southeast-1a"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.Public-SG.id}"]
    subnet_id = "${aws_subnet.Public-Sub.id}"
    associate_public_ip_address = true
    source_dest_check = false
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install python python-pip openjdk-8-jre -y
                EOF
    tags {
        Name = "jump"
    }
}

resource "aws_instance" "Wordpress" {
    ami = "${var.amis}"
    count = 1
    availability_zone = "ap-southeast-1a"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.Public-SG.id}"]
    subnet_id = "${aws_subnet.Public-Sub.id}"
    associate_public_ip_address = true
    source_dest_check = false
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install python python-pip openjdk-8-jre -y
                EOF
    tags {
        Name = "Wordpress"
    }
}

resource "aws_instance" "DB" {
    ami = "${var.amis}"
    count = 1
    availability_zone = "ap-southeast-1b"
    instance_type = "t2.micro"
    key_name = "${var.key_name}"
    vpc_security_group_ids = ["${aws_security_group.DB-SG.id}"]
    subnet_id = "${aws_subnet.Private-Sub.id}"
    associate_public_ip_address = true
    source_dest_check = false
    user_data = <<-EOF
                #!/bin/bash
                apt update -y
                apt install python python-pip openjdk-8-jre -y
                EOF
    tags {
    Name = "Database"
    }
}

output "aws_instance_public_dns" {
   value = "{aws_instance.wordpress.public_dns}"
   value = "{aws_instance.DB.public_dns}"
   value = "{aws_instance.jump.public_dns}"
}
