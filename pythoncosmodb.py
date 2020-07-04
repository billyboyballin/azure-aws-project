# Import packages

import pandas as pd
import json
from azure.cosmos import CosmosClient, PartitionKey, exceptions

print('Imported packages successfully.')

# Initialize the Cosmos client

url = "",
key = ""

client = CosmosClient(url, credential=key)

# Create database

database_name = 'testDatabase'
try:
    database = client.create_database(database_name)
except exceptions.CosmosResourceExistsError:
    database = client.get_database_client(database_name)

# Create container

container_name = 'products'
try:
    container = database.create_container(id=container_name, partition_key=PartitionKey(path="/productName"))
except exceptions.CosmosResourceExistsError:
    container = database.get_container_client(container_name)
except exceptions.CosmosHttpResponseError:
    raise

# Insert data
database_client = client.get_database_client(database_name)
container_client = database.get_container_client(container_name)

for i in range(1, 10):
    container_client.upsert_item({
            'id': 'item{0}'.format(i),
            'productName': 'Widget',
            'productModel': 'Model {0}'.format(i)
        }
    )

# Query
database = client.get_database_client(database_name)
container = database.get_container_client(container_name)

import json
for item in container.query_items(
        query='SELECT * FROM mycontainer r WHERE r.id="item3"',
        enable_cross_partition_query=True):
    print(json.dumps(item, indent=True))
