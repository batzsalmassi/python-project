docker run -d \
  -e SHODAN_API_KEY=$SHODAN_API_KEY \
  -p 80:80 \
  seansal/shodan_app:latest
