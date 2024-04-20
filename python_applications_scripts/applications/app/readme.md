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
# we can access the website and see realtime logs using this command

<!-- Docker cheatsheet -->
  attach      Attach local standard input, output, and error streams to a running container
  build       Build an image from a Dockerfile
  commit      Create a new image from a container's changes
  cp          Copy files/folders between a container and the local filesystem
  create      Create a new container
  diff        Inspect changes to files or directories on a container's filesystem
  events      Get real time events from the server
  exec        Run a command in a running container
  export      Export a container's filesystem as a tar archive
  history     Show the history of an image
  images      List images
  import      Import the contents from a tarball to create a filesystem image
  info        Display system-wide information
  inspect     Return low-level information on Docker objects
  kill        Kill one or more running containers
  load        Load an image from a tar archive or STDIN
  login       Log in to a Docker registry
  logout      Log out from a Docker registry
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  port        List port mappings or a specific mapping for the container
  ps          List containers
  pull        Pull an image or a repository from a registry
  push        Push an image or a repository to a registry
  rename      Rename a container
  restart     Restart one or more containers
  rm          Remove one or more containers
  rmi         Remove one or more images
  run         Run a command in a new container
  save        Save one or more images to a tar archive (streamed to STDOUT by default)
  search      Search the Docker Hub for images
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  tag         Create a tag TARGET_IMAGE that refers to SOURCE_IMAGE
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
  version     Show the Docker version information
  wait        Block until one or more containers stop, then print their exit codes