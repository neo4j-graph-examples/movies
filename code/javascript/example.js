// npm install --save neo4j-driver
// node example.js
var neo4j = require('neo4j-driver');
var driver = neo4j.driver('bolt://<HOST>:<BOLTPORT>', 
                  neo4j.auth.basic('<USERNAME>', '<PASSWORD>'), 
                  {/* encrypted: 'ENCRYPTION_OFF' */});

var query = 
  `
  MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie) 
  WHERE movie.title = $favorite 
  RETURN rec.title as title, count(*) as freq 
  ORDER BY freq DESC LIMIT 5 
  `;

var params = {"favorite": "The Matrix"};

var session = driver.session({database:"neo4j"});

session.run(query, params)
  .then(function(result) {
    result.records.forEach(function(record) {
        console.log(record.get('title'));
    })
	session.close();
    driver.close();
  })
  .catch(function(error) {
    console.log(error);
  });
