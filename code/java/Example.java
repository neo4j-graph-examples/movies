// Java Driver Dependency: http://search.maven.org/#artifactdetails|org.neo4j.driver|neo4j-java-driver|4.0.1|jar
// Reactive Streams http://search.maven.org/#artifactdetails|org.reactivestreams|reactive-streams|1.0.3|jar
// javac -cp neo4j-java-driver-*.jar Example.java && java -cp neo4j-java-driver-*.jar:reactive-streams-*.jar:. Example

import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

import java.util.List;
import static java.util.Collections.singletonList;

public class Example {

    public static void main(String...args) {
        try (Driver driver = GraphDatabase.driver("neo4j://<HOST>:7687",AuthTokens.basic("<HOST>","<PASSWORD>"));
             Session session = driver.session()) {
            String cypherQuery =
                    "MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie) "+
                    "WHERE movie.title IN $favorites "+
                    "RETURN rec.title as title, count(*) as freq "+
                    "ORDER BY freq DESC LIMIT 5";
            List<Record> records =
                    session.readTransaction(tx -> tx.run(cypherQuery, parameters("favorites", singletonList( "The Matrix" ))).list());
            records.forEach(record -> System.out.println( record.get( "title" ).asString()));
        }
    }
}


