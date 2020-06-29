# pip install neo4j

from neo4j import (
    GraphDatabase,
    basic_auth,
)

scheme = "neo4j"
port = 7687
host_name = "example.com"
user_name = "example_user"
user_password = "example_password"

uri = "{scheme}://{host_name}:{port}".format(scheme=scheme, host_name=host_name, port=port)

driver = GraphDatabase.driver(uri, auth=basic_auth(user_name, user_password))

cypher_query = '''
MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie)
WHERE movie.title IN $favorites
RETURN rec.title as title, count(*) as freq
ORDER BY freq DESC LIMIT 5
'''

with driver.session() as session:
    result = session.run(cypher_query, parameters={"favorites": ["The Matrix"]})

    for record in result:
        print("title: {} freq: {}".format(record["title"], record["freq"]))

driver.close()
