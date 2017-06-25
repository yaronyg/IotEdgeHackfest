# We have to use 16.10 because Bill Berry told me the version of CMAKE in 16.04 makes IoT Edge unhappy
FROM ubuntu:16.10

ENV INITSYSTEM=on

# Update image
RUN apt-get update 
RUN apt-get install -y curl build-essential libcurl4-openssl-dev git cmake pkg-config libssl-dev uuid-dev valgrind jq libglib2.0-dev libtool autoconf autogen vim

# For .net core 1.1.1
# WORKDIR /usr/src/app
# ADD . /usr/src/app
# # Libunwind is needed by the dotnet-install.sh script
# RUN apt-get install -y libunwind-dev
# RUN curl https://dot.net/v1/dotnet-install.sh > dotnet-install.sh
# # Although the dotnet-install.sh script claims to have no bashisms, it's not true, so I need to manually run it with bash
# # https://docs.microsoft.com/en-us/dotnet/core/tools/dotnet-install-script - Options for the script
# RUN /bin/bash -c "./dotnet-install.sh"

# Install .net core per https://www.microsoft.com/net/core#linuxubuntu
RUN sh -c 'echo "deb [arch=amd64] https://apt-mo.trafficmanager.net/repos/dotnet-release/ yakkety main" > /etc/apt/sources.list.d/dotnetdev.list'
# apt-key requires dirmngr which isn't installed by default
RUN apt-get install -y dirmngr
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 417A0893
# Update will fail if we don't have apt-transport-https to enable https updates
RUN apt-get install -y apt-transport-https
RUN apt-get update
# 1.0.1 of the dotnet tool will give us .net core 1.1.1 which is what the current release of IoT Edge is built against
RUN apt-get install -y dotnet-dev-1.0.1

# Checkout code
WORKDIR /usr/src/app
RUN git clone https://github.com/yaronyg/iot-edge.git

# Build IoT Edge Infrastructure
WORKDIR /usr/src/app/iot-edge/tools
RUN ./build.sh --enable-dotnet-core-binding

# RUN
WORKDIR /usr/src/app/iot-edge/build/samples/dotnet_core_module_sample
CMD ["./dotnet_core_module_sample", "/usr/src/app/iot-edge/samples/dotnet_core_managed_gateway/dotnet_core_managed_gateway_lin.json"]