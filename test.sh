#/bin/sh

BOLTPORT=7687
HOST=localhost
USERNAME=neo4j
PASSWORD=secret
EXPECT="Cloud Atlas"
JAVA_DRIVER_VERSION=4.0.1
RX_VERSION=1.0.3

docker run -d --name example-test -p $BOLTPORT:$BOLTPORT -v `pwd`/scripts:/scripts --env NEO4J_AUTH=$USERNAME/$PASSWORD neo4j:3.5
DOCKER_ID=$(docker ps -a -q -f name=example-test)
echo $DOCKER_ID

sleep 10
docker logs $DOCKER_ID

docker exec $DOCKER_ID sh -c "cat /scripts/import.cypher | /var/lib/neo4j/bin/cypher-shell -u $USERNAME -p $PASSWORD -a bolt://$HOST:$BOLTPORT"

docker exec $DOCKER_ID sh -c "echo 'MATCH (n) RETURN count(*);' | /var/lib/neo4j/bin/cypher-shell -u $USERNAME -p $PASSWORD -a bolt://$HOST:$BOLTPORT"

mkdir tmp
cd tmp

npm install --save neo4j-driver 
sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/<USERNAME>/$USERNAME/g" -e "s/<PASSWORD>/$PASSWORD/g" ../code/javascript/example.js > example.js
node example.js | grep "$EXPECT" || echo "JAVASCRIPT FAIL"

pip install neo4j-driver
sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/<USERNAME>/$USERNAME/g" -e "s/<PASSWORD>/$PASSWORD/g" ../code/python/example.py > example.py
python example.py | grep "$EXPECT" || echo "PYTHON FAIL"

curl -sOL https://repo1.maven.org/maven2/org/reactivestreams/reactive-streams/${RX_VERSION}/reactive-streams-${RX_VERSION}.jar
curl -sOL https://repo1.maven.org/maven2/org/neo4j/driver/neo4j-java-driver/${JAVA_DRIVER_VERSION}/neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar

sed -e "s/<BOLTPORT>/$BOLTPORT/g" -e "s/<HOST>/$HOST/g" -e "s/<USERNAME>/$USERNAME/g" -e "s/<PASSWORD>/$PASSWORD/g" ../code/java/Example.java > Example.java

javac -cp neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar Example.java
java -cp neo4j-java-driver-${JAVA_DRIVER_VERSION}.jar:reactive-streams-${RX_VERSION}.jar:. Example  | grep "$EXPECT" || echo "JAVA FAIL"

cd .. 
rm -rf tmp
docker rm -f $DOCKER_ID