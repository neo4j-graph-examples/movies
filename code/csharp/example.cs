//Install-Package Neo4j.Driver -Version 4.0.1
//Connecting to a 3.5.x Neo4j instance

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Neo4j.Driver;

public class SimpleExample
{
	private readonly IDriver _driver;
	public SimpleExample(string uri, string user, string password)
	{
		_driver = GraphDatabase.Driver(uri, AuthTokens.Basic(user, password), builder => builder.WithEncryptionLevel(EncryptionLevel.None));
	}
	
	public async Task<IEnumerable<string>> GetMovieRecommendations(string favoriteMovieTitle)
	{
		var cypherQuery =
			  @$"MATCH (movie:Movie)<-[:ACTED_IN]-(actor)-[:ACTED_IN]->(rec:Movie) 
				WHERE movie.title IN ${nameof(favoriteMovieTitle)}
				RETURN rec.title AS title, count(*) AS freq
				ORDER BY freq DESC LIMIT 5";
		IAsyncSession session = _driver.AsyncSession();
		var runQuery = await session.ReadTransactionAsync(async tx =>
		{
			var result = await tx.RunAsync(cypherQuery, new { favoriteMovieTitle });
			return await result.ToListAsync();
		});
		await session?.CloseAsync();
		return runQuery.Select(q => q.Values["title"].As<string>());
	}
	
	public static void WriteToConsole(IEnumerable<string> titles)
	{
		foreach (var title in titles)
			Console.WriteLine(title);
	}
	
	public static async Task Main()
	{
		var example = new SimpleExample("bolt://<HOST>:<BOLTPORT>", "<USERNAME>", "<PASSWORD>");
		var movies = await example.GetMovieRecommendations("The Matrix");
		WriteToConsole(movies);
	}
}
