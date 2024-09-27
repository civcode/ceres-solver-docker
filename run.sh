#!/bin/bash

#!/bin/bash

HOST_USER=${USER}

docker run -d -it \
    -v /home/$USER/workspace:/home/${HOST_USER}/workspace \
    ceres-solver
