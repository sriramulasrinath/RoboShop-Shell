instances=("mongodb" "redis" "mysql" "rabbitmq" "catalogue" "user" "cart" "shipping" "payment" "web")

hosted_zone_id="Z097760412NZYP4P1P7PG"

domain_name="srinath.online"


for name in ${instances[@]}; do
    if [$name == "shipping"] || [$name =="mysql"]
    then
        instance_type="t3.medium"
    else
        instance_type="t3.micro"
    fi 
    echo "Creating instnaces for: $name with instance_type: $instance_type"

    instance_id= $(aws ec2 run-instances --image-id ami-041e2ea9402c46c32  --instance-type $instance_type 
     --subnet-id subnet-abcd1234 --security-group-ids sg-abcd1234 'Instances[0].InstanceId' --output text)
     echo "Instance created for: $name"

     aws ec2 create-tags \  
    --resources $instance_id \
    --tags Key=Name,Value=$name

    if [$name == "web"]
    then
        aws ec2 wait instance-running --instance-ids $instance_id
        public_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        ip_to_use=$public_ip
    else
        private_ip=$(aws ec2 describe-instances --instance-ids $instance_id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        ip_to_use=$private_ip
    fi 

    echo "creating R53 record for $name"

    aws route53 change-resource-record-sets \
  --hosted-zone-id $hosted_zone_id \
  --change-batch '
  {
    "Comment": "Testing creating a record set"
    ,"Changes": [{
      "Action"              : "UPSERT"
      ,"ResourceRecordSet"  : {
        "Name"              : "'" $name.$domain_name "'.online.com"
        ,"Type"             : "CNAME"
        ,"TTL"              : 1
        ,"ResourceRecords"  : [{
            "Value"         : "'" $ip_to_use "'"
        }]
      }
    }]
  }
  '

     