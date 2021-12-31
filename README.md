# Image-Uploader
Deploys a 3 Tier Web App on AWS with Packer and Terraform. 

## Infrastructure on AWS
- Nginx on public subnet
- Node app on private subnet
- MongoDB on different private subnet

## Packer
Packer creates 3 different AMIs, and it configures them to run the application by running the corresponding script from the folder.  
There are 3 hcl files in the Packer folder
- nginx.pkr.hcl - For the nginx reverse proxy
- app.pkr.hcl - For the Node app
- mongo.pkr.hcl - For the mongo database

## Terraform
Creates a custom VPC and make 1 public (For Nginx) and 2 private subnets (For Node). Then creates 3 security groups with inbound and outbound traffic rules configured. 
Finally, it creates the instances and attach them to the corresponding subnet and security group. 
