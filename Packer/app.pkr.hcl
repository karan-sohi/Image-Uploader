locals { 
  timestamp = regex_replace(timestamp(), "[- TZ:]", "") 
}

source "amazon-ebs" "example" {
  ami_name      = "packer nginx ${local.timestamp}"
  instance_type = "t2.micro"
  region        = "us-east-1"

  source_ami_filter {
    filters = {
      name                = "amzn2-ami-hvm-2.*-x86_64-gp2"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["amazon"]
  }

  ssh_username = "ec2-user"
}


build {
  # The source we just declared
  sources = ["source.amazon-ebs.example"]

  # Run the nginx.sh configuration bash script

  provisioner "file" {
    source      = "./ImageApp.service"
    destination = "/tmp/ImageApp.service"
  }

  provisioner "file" {
    source      = "./app.env"
    destination = "/tmp/app.env"
  }

  provisioner "shell" {
    script = "./app.sh"
  }
}