// Java Driver Dependency: http://search.maven.org/#artifactdetails|org.neo4j.driver|neo4j-java-driver|4.0.1|jar
// Reactive Streams http://search.maven.org/#artifactdetails|org.reactivestreams|reactive-streams|1.0.3|jar
// javac -cp neo4j-java-driver-*.jar Example.java && java -cp neo4j-java-driver-*.jar:reactive-streams-*.jar:. Example

import org.neo4j.driver.*;
import static org.neo4j.driver.Values.parameters;

import java.util.List;
import static java.util.Arrays.asList;
import static java.util.Collections.singletonMap;

public class Example {

    public static void main(String...args) {
        Config noSSL = Config.builder().withoutEncryption().build();
        try (Driver driver = GraphDatabase.driver("bolt://<HOST>:<BOLTPORT>",AuthTokens.basic("<USERNAME>","<PASSWORD>"),noSSL);
		     Session session = driver.session()) {
            String cypherQuery =
                "MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie) "+
                "WHERE movie.title IN $favorites "+
                "RETURN rec.title as title, count(*) as freq "+
                "ORDER BY freq DESC LIMIT 5";
            Result result = session.run(cypherQuery, parameters("favorites",asList("The Matrix")));
            while (result.hasNext()) {
                System.out.println(result.next().get("title").asString());
            }
	    }
    }
}


