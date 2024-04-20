## Build and push docker image along with usage of docker compose 

<!-- Build a docker image -->
# docker build -t imagename:imageversion .
# docker build . -t compliancescanner:v1

<!-- List docker images -->
# docker images 

<!-- Remove docker image -->
# docker images rm image id 

<!-- Run the docker image on host port -->
# docker run -d -p hostport:containerport imagename:imageversion
# docker run -d -p 5000:50000  compliancescanner:v1

<!-- Push the docker image to docker hub -->
#  docker image tag compliancescanner:v1 devdockertesting/debarshi_04101991:compliancescannerv1
#  docker image push devdockertesting/debarshi_04101991:compliancescannerv1

<!-- Note: -->
Make sure the application is not running on loopback ip
Make sure the container is exposed on a certain port so that internal communication can happen using that port 

<!-- ## For troubleshooting after running the container -->
run
docker exec -it containerid bash
# docker ls 
# verify the files are copied or not 
# Then do
# curl localhost:5000

docker container attach containerid , Basically it will output whats going on in the container

## Convert a docker compose to a Kubernetes yaml file
Download the kompose tool and just browse to the dockercompose directory 

Type kompose convert it will automactically pick the compose file and yeild all the kubernetes yamls

## Convert kuberetes yamls to helm chart using helmify
https://github.com/arttor/helmify
helmify -f /my_directory mychart