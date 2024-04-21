# TestDockerFile-3

docker build -t testing . 

docker run -it -p 80:10101 --env-file=.env testing

// or

docker run --platform linux/amd64 -it -p 80:10101 --env-file=.env movingtowardsadream/test-docker-file-3
