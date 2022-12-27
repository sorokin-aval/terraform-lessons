import boto3
# Global variables, please fill with the correct information from the ASAv's
# =========================================================
asav_active = "i-04aeacc9c37ec1230"
asav_standby = "i-0d09081fc7151d4b2"
eni_active_inside = "eni-0541f28d04e37f41a"
eni_active_outside = "eni-02bf82a47ab6caae1"
active_priavteIP_outside = "10.226.176.76"

eni_standby_inside = "eni-0be333aa46af50e6e"
eni_standby_outside = "eni-07bc14a4e789f998c"
standby_privateIP_outside = "10.226.176.88"

active_publicIP = "3.71.212.2"
active_publicIP_allocationId = "eipalloc-07c0abcc19a519ef1"
# =========================================================
# End of Global Variables
def switch_routes(client, asa_get, eni_active, eni_standby):
    # We will filter only the route tables that have routes pointing to the active ASAvA
    route_tables = client.describe_route_tables(Filters=[{'Name': 'route.instance-id','Values': [asa_get]}])
    
    # This variable will save the number of route tables
    n = len(route_tables['RouteTables'])
    # Now we will iterate through each route table
    for i in range(n):
        # This variable will save the route table id for later execution
        routeid = route_tables['RouteTables'][i]['RouteTableId']
        # This variable will save the number of route entries within the route table
        m = len(route_tables['RouteTables'][i]['Routes'])
        # Now we will iterate through each route entry
        for j in range(m):
            # This variable will save the route entry for comparison
            route = route_tables['RouteTables'][i]['Routes'][j]
            # We need this because not all the route entries have NetworkInterfaceId as the gateway, so we avoid those errors
            try:
                # We compare now if the NetworkInterfaceId is tha same as the active ASA, and if it is the case, we proceed to replace the route entry with the new ASAvB
                if route['NetworkInterfaceId'] == eni_active:
                    destination = route['DestinationCidrBlock']
                    client.replace_route(
                        DestinationCidrBlock=destination,
                        NetworkInterfaceId=eni_standby,
                        RouteTableId=routeid)
            except KeyError:
                continue

def switch_eni(client, eni, privateIP):
    client.disassociate_address(
        PublicIp=active_publicIP)

    client.associate_address(
        AllocationId=active_publicIP_allocationId,
        NetworkInterfaceId=eni,
        PrivateIpAddress=privateIP)

def lambda_handler(event, context):
    print(event,context)
    # Here we are calling the ec2 client SDK from boto3
    client = boto3.client('ec2')
    if event.get("source"):
    #launch failover ec2
        ec2 = boto3.resource('ec2')
        instance = ec2.Instance(id=asav_standby)
        instance.start()
        instance.wait_until_running()
        asa_get, eni_active, eni_standby = asav_active,eni_active_inside,eni_standby_inside
        eni, privateIP = eni_standby_outside, standby_privateIP_outside
    else:
        asa_get, eni_active, eni_standby = asav_standby,eni_standby_inside,eni_active_inside
        eni, privateIP =  eni_active_outside, active_priavteIP_outside
    switch_routes(client,asa_get,eni_active,eni_standby)   
    # In this last section we are swapping the public EIP's from both ASAv's outside interfaces
    switch_eni(client,eni,privateIP)
