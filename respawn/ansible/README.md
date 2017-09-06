How to use this ansible
=========


Configure
------------

Configure your ansible-vault password at file private/.vault_pass
Update the group_vars/rs_servers/vault and reencrypt using below command 

ansible-vault encrypt group_vars/rs_servers/vault

edit the ansible.cfg with values private_key_file to your appropriate AWS PEM key file

roles/aws/defaults
fqdn_domain: "respawn.internal"
security_key: "ska-play"
security_group: "ska-sg-aws"

create-image, launch-configuration
security_groups: ["sg-aafa79d3"]

TODO: 
Work upon the security group configuration
Create separate security group for public / private 
subnet is in 2b -> set to 2c 
 

brew install jq
sudo yum install -y jq

export AWS_ACCESS_KEY_ID='XXXXXXXX'
export AWS_SECRET_ACCESS_KEY='XXXXXXXXXXXXXXXX'



ansible-playbook 03.install.utils.yml -i 'ec2-34-213-92-128.us-west-2.compute.amazonaws.com' --connection=local

cd ..
rm -f ansible.tar.gz
tar -cvzf ansible.tar.gz ansible/
scp -i ~/.ssh/ava-us-west-2.pem   ansible.tar.gz ec2-user@ec2-34-213-92-128.us-west-2.compute.amazonaws.com:/home/ec2-user/
cd ansible/

ssh -i ~/.ssh/ava-us-west-2.pem ec2-user@ec2-34-213-92-128.us-west-2.compute.amazonaws.com
cd ~/
rm -f ansible/
tar -xvzf ansible.tar.gz 
cd ansible

ansible-playbook 03.install.utils.yml -i 'ec2-34-213-92-128.us-west-2.compute.amazonaws.com,' --extra-vars='vault_aws_access_key=XXXXXX vault_aws_secret_key=XXXXXXXXXXXX'



Create VPC
------------

Create a VPC and Dynamic DNS. Check all the default vars in roles/vpc-setup/defaults/main.yml 

ansible-playbook 00.create.vpc.yml


Provision Hardware
------------

Run the below command to provision a replicaset of 3 members. Each member would be create in AWS, ebs volumes for swap and MongoDB data, populates both instances and volumes with certain tags. A new inventory file is created in inventories/<_server_group_name_>

ansible-playbook 01.provision.yml --extra-vars='security_key=ava-us-west-2 security_group=default vpc_subnet_id=subnet-74d37412 availability_zone=us-west-2b'


Create replicaset
--------------

A description of the settable variables for this role should go here, including any variables that are in defaults/main.yml, vars/main.yml, and any variables that can/should be set via parameters to the role. Any variables that are read from other roles and/or the global scope (ie. hostvars, group vars, etc.) should be mentioned here as well.

missed the ansible.cfg settings pointing to /home/ec2-user/
scp -i ~/.ssh/ava-us-west-2.pem   ~/.ssh/ava-us-west-2.pem ec2-user@ec2-34-213-92-128.us-west-2.compute.amazonaws.com:/home/ec2-user/.ssh/

no internet
create nat in public subnet not private 
10.12.200.0/24,10.12.100.0/24

private_key_file = /Users/shyamarjarapu/.ssh/ava-us-west-2.pem
changed the hosts to use internal ips rather than public ips for ansible inventory

ansible-playbook 02.replicaset.yml -i inventories/skamon_demoapp_rs --extra-vars '{"replset_name":"rsdemo","mongo_port":28000}' 

make the alias resolvable to private dns not public

Install the utilities
--------------

Each server of replicaSet are expected to have certain utilities preinstalled on them. Make sure the inventories/rs_servers is renamed accordingly should you choose to change it.

public ip address in inventory file?
no outgoing internet 
had to manually flip the hosts:all to hosts:rs_servers

ansible-playbook 03.install.utils.yml -i inventories/skamon_demoapp_rs --extra-vars='source_pem_key_file=/home/ec2-user/.ssh/ava-us-west-2.pem'

Create Auto Scaling Group
------------



ansible-playbook 04.create.auto.scale.group.yml  -i inventories/skamon_demoapp_rs


Integrity Check
------------

A list of other roles hosted on Galaxy should go here, plus any details in regards to parameters that may need to be set for other roles, or variables that are used from other roles.

ansible-playbook 10.check.mounts.yml  -i inventories/skamon_demoapp_rs


Plan of execution
----------------

keep things simple - lambda, may be route 53 out
figure out better way to assign fqdn .uswest is fine
so whenever something new kicks in. it needs to take the fqdn of what went down
may be have script running on crontab for every 1 min
	* it checks if the device has /data mapping
	* if it has exit. if not fetch the instance id 
	* find the auto scaling group that has current instance_id
	* find all the instance ids of the auto scaling group
	* find the server_group_name and server_number from tags (Who populates these tags for you?)
	. if they are blank exit. if not query for volumes by above combo
	. if not found exit. if found, force detach and attach to current instance (remember the order)
	. update fstab if required, i dont think you do
	. create the folder and mount the devices 
	. restart the mongod

Who populates the tags for you?
	. Way 1: for one of the instance fetch server_group_name and server_number, find all volumes not mounted, grab the instance_name from there (works if volumes are unmounted, )
	. Way 2: from the server_groupname, get the terminated instance_ids with same group name (assumes the terminated instance is still available, not for long though)
	. Way 3: Fetch the dead instance id read it from dynamoDB using ARN (Probably best)
	. Way 4: But I think you may have to use Atlas to keep it as MongoDB (Company point of view)
	. Common: Apply all the tags from the found image to current instance
	. Issues: What if two goes down at same time? Would two servers try to mount save server_number ? Sol: May be add some random sleep for now. check if any vols with current instance private ip, if yes mount it here. if not mount another vol. not found do nothing. may be through warning

Python or Nodejs - for reading from aws
Shell or Ansible
DynamoDB or MongoDB - for reading from db

curl http://169.254.169.254/latest/meta-data/
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html

ami_skamon_demoapp_rs
lc_skamon_demoapp_rs
asg_skamon_demoapp_rs

aws:autoscaling:groupName	ami2_skamon_demoapp_rs

server_group_name	skamon_demoapp_rs


https://github.com/atplanet/ansible-auto-scaling-tutorial
http://vcdxpert.com/?p=193

pending
Unhealthy

License
-------

[x] Add ZONE and CNAME tags to server and volumes.
[x] Check if the device has /data mapping
[x] if it has exit. if not fetch the instance id
[x] find instance tags: auto_scaling_group, server_group_name and server_number
[x] Optional: find the all the instance ids of the above auto scaling group
[x] find the server_group_name and server_number from tags
[x] if they are blank exit. if not query for volumes by above combo
[ ] if not found exit. if found, force detach and attach to current instance (remember the order)
[ ] update fstab if required, i dont think you do
[ ] create the folder and mount the devices 
[ ] restart the mongod
[ ] Ansible to run logic, ship to image when deploying
[ ] Crontab to invoke playbook

https://stackoverflow.com/questions/35133299/launch-a-shell-script-from-lambda-in-aws
Security. As of today lambda can't run in VPC. Which means your EC2 has to have a wide open inbound security group.
Lambda. Get message; send to SQS
EC2. Cron job that gets trigger N number of minutes. pull message from sqs; process message.

https://aws.amazon.com/blogs/compute/scheduling-ssh-jobs-using-aws-lambda/

Author Information
------------------

An optional section for the role authors to include contact information, or a website (HTML is not allowed).
