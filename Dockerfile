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
# 1.0.4 of the dotnet tool will give us .net core 1.1.2 but to use that, at a minimum, we have to update dotnet_core_loader.h
RUN apt-get install -y dotnet-dev-1.0.1

# Checkout code
WORKDIR /usr/src/app
RUN git clone https://github.com/yaronyg/iot-edge.git


# Build IoT Edge Infrastructure
WORKDIR /usr/src/app/iot-edge/tools
# BUGBUG: I'm fairly sure that build_dotnet_core.sh isn't needed, that build.sh calls it
RUN ./build_dotnet_core.sh
RUN ./build.sh --enable-dotnet-core-binding

# RUN
WORKDIR /usr/src/app/iot-edge/build/samples/dotnet_core_module_sample
CMD ["./dotnet_core_module_sample", "/usr/src/app/iot-edge/samples/dotnet_core_managed_gateway/dotnet_core_managed_gateway_lin.json"]


## cat config file into env var
# ENTRYPOINT J_FILE=$(cat /usr/src/app/iot-edge/samples/simulated_device_cloud_upload/src/simulated_device_cloud_upload_lin.json) \

#     # cd into sample dir
#     && cd /usr/src/app/iot-edge/samples/simulated_device_cloud_upload/src/ \

#     # update settings based on env vars
#     && echo "$J_FILE" \ 
#     #configure iot hub
#     | jq '.modules[0].args.IoTHubName="'$IoTHubName'"' \
#     | jq '.modules[0].args.IoTHubSuffix="'$IoTHubSuffix'"' \
#     | jq '.modules[0].args.Transport="AMQP"' \
#     # configure device 1
#     | jq '.modules[1].args[0].deviceId="'$device1'"' \
#     | jq '.modules[1].args[0].deviceKey="'$device1key'"' \
#     # configure device 2
#     | jq '.modules[1].args[1].deviceId="'$device2'"' \
#     | jq '.modules[1].args[1].deviceKey="'$device2key'"' \
    
#     # uncomment the following line to set device 1 message period
#     #| jq '.modules[2].args.messagePeriod=30000' \
    
#     # uncomment the following line to set device 2 message period
#     #| jq '.modules[3].args.messagePeriod=30000' \
    
#     # save changes
#     > replaced.json \

#     # cd back up to build dir
#     && cd /usr/src/app/iot-edge/build/ \

#     # run gateway with new config file
#     && ./samples/simulated_device_cloud_upload/simulated_device_cloud_upload_sample ../samples/simulated_device_cloud_upload/src/replaced.json
