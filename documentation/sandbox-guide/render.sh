echo "Usage: sh render.sh [publish]"
BUILD=./build

function render {
$BUILD/run.sh movies.adoc index.html +1 "$@"

}

if [ "$1" == "publish" ]; then
  URL=BUILD.neo4j.com/sandbox/movies
  render http://$URL
  if hash aws 2>/dev/null; then
    aws s3 cp --acl public-read --recursive --exclude "*" --include "*.html" --include "*.png" --include "*.jpg" --include "*.gif" . s3://${URL}/
    aws s3 cp --acl public-read index.html s3://${URL}
  else
    s3cmd put --recursive -P *.html img s3://${URL}/
    s3cmd put -P index.html s3://${URL}
  fi
  echo "Publication Done"
elif [ "$1" == "render-only" ]; then
  URL=guides.neo4j.com/sandbox/movies
  render http://$URL
else
  URL=localhost:8001/
  render http://$URL
  echo "Starting Websever at $URL Ctrl-c to stop"
  python $BUILD/http-server.py
fi
