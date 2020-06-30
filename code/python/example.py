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

def get_recomended_movies(transaction, favorites):
    # this is a transaction function,
    # this function can be retried by the transaction manager

    cypher_query = '''
    MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie)
    WHERE movie.title IN $favorites
    RETURN rec.title as title, count(*) as freq
    ORDER BY freq DESC LIMIT 5
    '''

    result = transaction.run(cypher_query, parameters={"favorites": favorites})

    movies = []

    for record in result:
        # the cypher_query defined the RETURN to have the keys "title" and "freq"
        movies.append(record["title"])

    return movies

with driver.session() as session:
    movies = session.read_transaction(get_recomended_movies, favorites=["The Matrix"])

    for movie in movies:
        print(movie)

driver.close()
