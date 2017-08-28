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

