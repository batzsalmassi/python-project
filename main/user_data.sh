
#!/bin/bash
yum update -y
yum install -y docker
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
export SHODAN_API_KEY=${{ secrets.SHODAN_API_KEY }}


# pull the most recent image from docker hub.
docker pull seansal/shodan_app:$(curl -s https://hub.docker.com/v2/repositories/seansal/shodan_app/tags/?page_size=1 | grep -oP '"name":\s*"\K[^"]+')

# run the image and establish the container
docker run -d -e SHODAN_API_KEY=$SHODAN_API_KEY -p 80:80 seansal/shodan_app:$(curl -s https://hub.docker.com/v2/repositories/seansal/shodan_app/tags/?page_size=1 | grep -oP '"name":\s*"\K[^"]+')
