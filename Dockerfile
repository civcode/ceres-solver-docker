FROM ubuntu:24.04

# Set environment variable to disable user interaction
ENV DEBIAN_FRONTEND=noninteractive

ARG UID
ARG GID
ARG USERNAME

# Install packages
RUN apt-get update && apt-get install -y \
    build-essential \
    cmake \
    cmake-curses-gui \
    # can-utils \
    curl \
    git \
    gpg-agent \
    htop \
    # iproute2 \
    # locales \
    # ncurses-dev \
    # mesa-utils \
    # rsync \
    sudo \
    # software-properties-common \
    tmux \
    unzip \
    vim \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install ceres dependencies
RUN apt-get update && apt-get install -y \
    # libatlas-base-dev \
    libeigen3-dev \
    libgflags-dev \ 
    libgoogle-glog-dev \
    libmetis-dev \
    # libopenblas-dev \
    libsuitesparse-dev \
    # libtbb-dev \
    && rm -rf /var/lib/apt/lists/*

# Install Intel MKL
RUN mkdir -p /var/dependencies \
    && cd /var/dependencies \
    && wget -O- https://apt.repos.intel.com/intel-gpg-keys/GPG-PUB-KEY-INTEL-SW-PRODUCTS.PUB \
    | gpg --dearmor | sudo tee /usr/share/keyrings/oneapi-archive-keyring.gpg > /dev/null \
    && echo "deb [signed-by=/usr/share/keyrings/oneapi-archive-keyring.gpg] \
    https://apt.repos.intel.com/oneapi all main" | sudo tee /etc/apt/sources.list.d/oneAPI.list \
    && apt-get update && apt-get install -y \
    intel-oneapi-mkl



# Build and install OpenBLAS 
# RUN mkdir -p /var/dependencies \
#     && cd /var/dependencies \
#     && git clone --depth 1 --branch v0.3.28 https://github.com/OpenMathLib/OpenBLAS.git OpenBlas \
#     && cd OpenBlas \
#     && make USE_THREAD=0 USE_LOCKING=1 -j8 \
#     && make PREFIX=/usr/local install

# Build and install Ceres Solver
# RUN mkdir -p /var/dependencies \
#     && cd /var/dependencies \
#     && git clone --depth 1 --branch 2.2.0 https://github.com/ceres-solver/ceres-solver.git ceres-solver \
#     && cd ceres-solver \
#     && mkdir build \
#     && cd build \
#     && cmake .. \
#     && make -j8 \
#     && make test -j8 \
#     && make install

# Install OMPL (Open Motion Planning Library)
# RUN mkdir -p /var/ompl \
#     && cd /var/ompl \
#     && wget https://ompl.kavrakilab.org/install-ompl-ubuntu.sh \
#     && chmod u+x install-ompl-ubuntu.sh \
#     && ./install-ompl-ubuntu.sh \
#     && rm -rf /var/ompl

# Install ROS2 Jazzy
# RUN locale-gen en_US en_US.UTF-8 \
#     && update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8 
    
# RUN add-apt-repository universe \
#     && curl -sSL https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -o /usr/share/keyrings/ros-archive-keyring.gpg \
#     && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/ros-archive-keyring.gpg] http://packages.ros.org/ros2/ubuntu $(. /etc/os-release && echo $UBUNTU_CODENAME) main" | tee /etc/apt/sources.list.d/ros2.list > /dev/null \
#     && apt-get update && apt-get install -y \ 
#     ros-dev-tools \
#     ros-jazzy-desktop

# Create a non-root user with sudo privileges
# Remove any user or group that conflicts with the desired UID/GID
RUN if getent passwd $UID; then \
      userdel -f $(getent passwd $UID | cut -d: -f1); \
    fi \
    && if getent group $GID; then \
      groupdel $(getent group $GID | cut -d: -f1); \
    fi
    
# Create the user and group with the specified UID and GID    
RUN addgroup --gid ${GID} ${USERNAME} \ 
    && adduser --uid ${UID} --gid ${GID} --disabled-password --gecos "" ${USERNAME} \
    && usermod -aG sudo ${USERNAME} \
    && echo "${USERNAME} ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers 

# Switch to the non-root user
USER ${USERNAME}

RUN mkdir -p /home/${USERNAME}/workspace \
    && cd /home/${USERNAME}/workspace \
    && git clone --depth 1 --branch 2.2.0 https://github.com/ceres-solver/ceres-solver.git 

# Append custom bashrc to the default bashrc
COPY custom_bashrc /home/${USERNAME}/
RUN cat /home/${USERNAME}/custom_bashrc >> /home/${USERNAME}/.bashrc \
    && rm /home/${USERNAME}/custom_bashrc
    
WORKDIR /home/${USERNAME}

CMD ["sleep", "infinity"]
