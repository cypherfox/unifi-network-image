# unifi-network-image
my own container images for the Unifi Network controller software


## Configuration Settings

these values can be set as environment values for the docker container

MEM_LIMIT   Number of Megabytes to restrict the running vm to. Default: 1024M

The image also receives MONGO_USER, MONGO_HOST, MONGO_PORT, MONGO_DBNAME, MONGO_PASS, but these are all set via the helm chart to access a database provided by the MongoDB Community Kubernetes Operator