Install MongoDB
=========

sudo tee /etc/yum.repos.d/mongodb-enterprise-3.2.repo <<EOF
[mongodb-enterprise-32]
name=MongoDB Enterprise Repository
baseurl=https://repo.mongodb.com/yum/redhat/\$releasever/mongodb-enterprise/3.2/\$basearch/
gpgcheck=1
enabled=1
gpgkey=https://www.mongodb.org/static/pgp/server-3.2.asc
EOF
sudo yum install -y mongodb-enterprise


Uninstall MongoDB
=========

sudo systemctl stop mongod
sudo yum -y erase $(rpm -qa | grep mongodb-enterprise)
sudo rm -rf /var/log/mongodb/*
sudo rm -rf /var/lib/mongodb/*
sudo rm -rf /var/run/mongodb/mongod.pid
sudo systemctl daemon-reload
ps -ef | grep mongod.conf 



Uninstall MongoDB
=========

# Create default AWS instances and build AMI
. Input replset name 
. Compose the instance / volume tags for the members
. Install mongodb on all three 
. Create replicaset  
. Take AMI snapshot

TODO: 
Update the instance to format the drive
mount the devices etc 

Instances:
Kills skamon_demoapp_rs03
Instance ID: i-0c985b5fa4f3e507a
Instance state: terminated

Auto scaling groups:
asg_skamon_demoapp_rs

Activity History
Terminating EC2 instance: i-0c985b5fa4f3e507a
Launching a new EC2 instance: i-0592e19d6ff99d7a5

Tags on i-0c985b5fa4f3e507a
Name	skamon_demoapp_rs03
aws:autoscaling:groupName	asg_skamon_demoapp_rs
expire-on	2017-09-30
owner	shyam.arjarapu
server_group_name	skamon_demoapp_rs
server_number	03

apply tags from terminated instance onto the new instance

attache the volumes of the old instances
Tags: 
instance_name	skamon_demoapp_rs03
device	/dev/xvdf

ansible / cli scripts needed
Stop mongod 
force unmount if applicable 
assign the ebs volumes to new server 
mount the volumes to server 
update the fstab 
Copy tags from old to new server 
start mongod 


# Instance State 
running
shutting-down
terminated

# Status Checks
Initializing
2/2 checks passed

# mongodb

## Steps

Flexibility
. ami instance id 
. mongodb version 
. application name
. replicaset name
. number of servers 

Create AWS instances with
Create mount points for /data /swap 
Add tags for servers / mount points with  
. application name
. replicaset name
. server number 

If one of the server in the group is terminated
I am assuming new server will replace the dead one
However the server which it replaced should mount the data files back on 
then start the mongodb 

Since the internal ip addresses will change our servers should have Route 53 for FQDN 
FDQN: app.repl.mon.server.organization.domain

The respawned server needs to figure which FQDN is terminated and needs to replace itself as it (keep it separate  for now)


https://aws.amazon.com/blogs/compute/building-a-dynamic-dns-for-route-53-using-cloudwatch-events-and-lambda/

https://github.com/RUNDSP/route53_autoscaling_syncer


VPC with Public and Private Subnets (NAT)
http://docs.aws.amazon.com/AmazonVPC/latest/UserGuide/VPC_Scenario2.html

https://blog.corpinfo.com/create-a-dynamic-dns-with-the-aws-api-route-53
https://github.com/sTywin/dyndns53

https://gist.github.com/reggi/dc5f2620b7b4f515e68e46255ac042a7

pip install awscli --upgrade --user
aws --version


https://www.youtube.com/watch?v=Qn8uGcfBb_I
https://www.youtube.com/watch?v=CP7yd7nOb5Q

VPC configuration 
routable 
main -> nat 
igw -> subnet assoc, edit add public subnet 
lambda func -> private subnets; security group all to private 


VPC
myvpcdfw 192.168.0.0/16

Subnet
dfwpublicvpc 192.168.10.0/24, no pref on az
dfwprivatevpc 192.168.20.0/24, no pref on az

Internet Gateway
dfwpublicIGW

dfwpublicvpc -> route table : edit add 0.0.0.0/0 -> IGW 
dfwprivatevpc -> route table : 



intention is to have new servers spin up when something go down 

auto scaling group name: prod.aviva.democluster.shard1

may be fetch all the members of the auto scaling group 
for each member in asg, check if tags are set 
if set, do nothing 
if not set, set the tags - 

objective is to set the cname and zone.
zone could be set at asg level 
cname should have prefix + server# 

asgn: prod.aviva.democluster.shard1
server prefix: prod.adc
server #: shard11
cname: prod.adc.shard11.avivadental.care.

given current : [i2,i3,i4]
got metrics for all []

maintain a collection of instances for replicaset from asg 
prod.aviva.democluster.shard1 : [i2,i3,i5]

i5 is not in DynamoDB, take the role of i4 
what if there are two, so lowcase sort and pick the ith replacement 
take the mappings from i4, cname, zone etc and put it back on i5 
kayka

now how about unmounting back the drives onto i5 
find the volumes by the tags and force detach and attach 
# invoke something on the i5 the updates the fstab, mounts data points etc 


