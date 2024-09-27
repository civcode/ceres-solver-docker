# Get your host's UID and GID
HOST_UID=$(id -u)
HOST_GID=$(id -g)
HOST_USER=${USER}

echo "docker build . --build-arg UID=$HOST_UID --build-arg GID=$HOST_GID --build-arg USERNAME=$HOST_USER -t ceres-solver"
docker build . --build-arg UID=$HOST_UID --build-arg GID=$HOST_GID --build-arg USERNAME=$HOST_USER -t ceres-solver