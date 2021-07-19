## terraform-ansible
This project sets up an EC2 instance inside a public subnet on AWS.
Ansible is then run to configure the instance with an Nginx docker container.

To run this, ensure that you have the following installed:

* aws-cli
* terraform

Execute the script file `project` with -c option to create all resources  
Execute the script file `project` with -d option to destroy all resources

When creating resources, a new file called `secret.pem` will be created. This is your private key to ssh into your aws instance:

`ssh -i secret.pem ubuntu@<public-ip-of-instance>`

