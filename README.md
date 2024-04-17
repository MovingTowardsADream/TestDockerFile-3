# TestDockerFile-3

docker build -t testing . 

docker run -it -p 80:10101 --env-file=.env testing
