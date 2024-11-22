
# creates a jenkins server which act as master in this usecase
module "jenkins" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.master_name

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-08eed4ca0fd852a9e"]
  subnet_id              = "subnet-0509f144a358e12de"
  user_data = file("jenkins.sh")

  # Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50 # GiB
        volume_type = "gp3" # general purpose ssd
        delete_on_termination = true # automatically delete the volumes when the instance is terminated
    }
  ]
  tags = {
    Name = var.master_name
  }
}

# creates a jenkins server which act as agent in this usecase
module "jenkins_agent" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  name = var.agent_name

  instance_type          = "t3.small"
  vpc_security_group_ids = ["sg-08eed4ca0fd852a9e"]
  subnet_id              = "subnet-0509f144a358e12de"
  user_data = file("jenkins-agent.sh")

  # Define the root volume size and type
  root_block_device = [
    {
        volume_size = 50 # GiB
        volume_type = "gp3" # general purpose ssd
        delete_on_termination = true # automatically delete the volumes when the instance is terminated
    }
  ]
  tags = {
    Name = var.agent_name
  }
}

# Create records for jenkins master, jenkins agent in route 53 
module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 3.0"

  zone_name = var.zone_name # divyavutakanti.com

  records = [
    {
      name    = "jenkins"  # jenkins.divyavutakanti.com
      type    = "A"
      ttl     = 1
      records = [module.jenkins.public_ip]
       allow_overwrite = true
    },
    {
      name    = "jenkins-agent"
      type    = "A"
      ttl     = 1
      records = [module.jenkins_agent.private_ip] # jenkins-agent.divyavutakanti.com
      
       allow_overwrite = true
    },
  ]
}