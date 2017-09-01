#!/bin/sh
# region="us-west-2"


# append the datetime maybe
# unmound the device 
# take snapshot tag the snapshot 
# create ami with the above snapshot id 
# create launch configuration
# create auto scaling group 0,3; desired 0
# attach servers to the group 
# aws autoscaling attach-instances --instance-ids i-a8e09d9c --auto-scaling-group-name my-asg


- name: create auto scaling group 
  hosts: local
  vars:
    - region: "us-west-2"
  tasks:
    - name: get the aws instance from ip address
      ec2_remote_facts:
        region: "{{ region }}"
        filters:
          private_dns_name: "{{ hostvars[groups.rs_servers[2]].private_dns }}"
      register: instance_check

    - name: display the instance details
      debug: msg="{{ instance_check.instances.0.tags }}"

    # - name: stop the server number 3 
    #   ec2:
    #     region: "{{ region }}"
    #     instance_ids: "{{ instance_check.instances.0.id }}"
    #     state: stopped
    #     wait: yes

    # # - name: display the instance details
    # #   debug: msg="{{ instance_check.instances.0.tags }}"

    # - name: create an ami image of instance 3
    #   ec2_ami:
    #     region: "{{ region }}"
    #     instance_id: "{{ instance_check.instances.0.id }}"
    #     wait: yes
    #     name: ami_skamon_demoapp_rs
    #     device_mapping:
    #       - device_name: /dev/sda1
    #         size: 10
    #         delete_on_termination: true
    #         volume_type: gp2
    #       - device_name: /dev/xvdb
    #         no_device: yes
    #       - device_name: /dev/xvdf
    #         no_device: yes
    #   register: image

    # - name: start the server number 3 
    #   ec2:
    #     region: "{{ region }}"
    #     instance_ids: "{{ instance_check.instances.0.id }}"
    #     state: running
    #     wait: yes

    # - name: create launch config
    #   vars:
    #     - image: {id: "ami-ea7c9692"}
    #   ec2_lc:
    #     region: "{{region}}"
    #     name: lc_skamon_demoapp_rs
    #     image_id: "{{image.id}}"
    #     key_name: "ska-play"
    #     security_groups: "sg-aafa79d3"
    #     instance_type: t2.micro
    #     assign_public_ip: yes
    ## sg-aafa79d3, ska-sg-aws, vpc-0cdb1d68

    # - name: create automatic scaling group
    #   ec2_asg:
    #     region: "{{region}}"
    #     name: asg_skamon_demoapp_rs
    #     launch_config_name: lc_skamon_demoapp_rs
    #     health_check_period: 60
    #     health_check_type: ELB
    #     replace_all_instances: yes
    #     vpc_zone_identifier: ['subnet-38241a61']
    #     min_size: 0
    #     max_size: 3
    #     desired_capacity: 0

    - name: add all the instances to the auto scaling group 
      

# # # Deregister AMI (delete associated snapshots too)
# # - ec2_ami:
# #     aws_access_key: xxxxxxxxxxxxxxxxxxxxxxx
# #     aws_secret_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# #     region: xxxxxx
# #     image_id: "{{ instance.image_id }}"
# #     delete_snapshot: True
# #     state: absent
