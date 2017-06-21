# IotEdgeHackfest
Playing with .net core on IoT Edge and looking at perf issues

# How I created the HelloWorld test module
I wanted to add a new module to the gateway. I could have done this with the dynamic module support but for some random reason I instead decided to do it by adding it to the existing solution file.

1. Clone https://github.com/yaronyg/iot-edge
1. Open Visual Studio 2017 (I tried 2015 but it didn't like the sln in iot-edge)
1. Open iot-edge\bindings\dotnetcore\dotnet-core-binding\dotnet-core-binding.sln in VS 2017
1. Go to Solution 'dotnet-core-binding', right click Add->New Project and choose '.NET Standard Class Library'
1. Place the new project under iot-edge\samples\dotnet_core_module_sample\modules and give it a reasonable name (e.g. FooModule)
1. In the new project change Class1.cs to the module name, typically this should be 'DotNetFooModule.cs'
1. Right click on the FooModule project and select properties and set the framework to .NETStandard1.3.
1. Right click on the Dependencies folder in the FooModule project inside of the project explorer and select 'Add Reference', in the dialog navigate to Projects->Solution and click on the box by Microsoft.Azure.Devices.Gateway
1. Now go to the dotnet_core_managed_gateway project in the project explorer, right click on Dependencies->Add Reference and under Projects->Solution click on FooModule.
1. Now go to iot-edge\tools\build_dotnet_core.cmd and add FooModule to projects-to-build (the format is obvious from the file)
1. Repeat the previous instruction with iot-edge\tools\build_dotnet_core.sh (we want things to work on Docker)
1. Now go to iot-edge\samples\dotnet_core_managed_gateway\dotnet_core_managed_gateway_win.json and add the module and any FooModule as a new modules entry and add an entry to links if necessary
1. Repeat the previous instruction with iot-edge\samples\dotnet_core_managed_gatway\dotner_core_managed_gateway_lin.json so Docker will work.
1. Go to iot-edge\MakeList.txt and add an entry for FooModule of the form dotnet_core_foo_dll, see dotnet_core_printer_dll for an example.
1. Go to iot-edge\samples\dotnet_core_module_sample\CMakeLists.txt and add an install_binaries line for FooModule, check out dotnet_core_printer_module_dll for an example.

# Running on Windows
## Setup
To set up the same environment as we are using on Docker on Linux I installed "1.1.1 with SDK 1.0.1" released on 2017/03/07 from https://github.com/dotnet/core/blob/master/release-notes/download-archives/1.1.1-download.md. I used SDK Installer for Windows, 32-bit. I used 32 bit because iot-edge defaults to it. We could use 64 bit, to do that go to tools/build.cmd and either submit the --platform argument when calling it or one can set build-platform on line 24 (or so) from Win32 to x64. But I'm going to stick with 32 since it really doesn't matter for the moment.

We also need to setup the dev box per https://github.com/Azure/iot-edge/blob/master/doc/devbox_setup.md#set-up-a-windows-development-environment.

## Launching the gateway
1. Open a Visual Studio Command Prompt (Start -> Developer Command Prompt for Visual Studio 2017)
2. Navigate to iot-edge\tools
3. Execute build_dotnet_core.cmd
4. Execute 'build.cmd --enable-dotnet-core-binding'
5. Navigate to iot-edge\build\samples\dotnet_core_module_sample\Debug\
6. Execute 'dotnet_core_module_sample ..\..\..\..\samples\dotnet_core_managed_gateway\dotnet_core_managed_gateway_win.json'

# Running on Docker
First, clone this depot since it has the Dockerfile we need:
git clone https://github.com/yaronyg/IotEdgeHackfest.git

Then navigate into the repro:
cd IotEdgeHackfest

Then build the docker image (yes, we'll eventually publish but for now things are changing a bit too fast for that):
docker build -t yarongmsft/hackfest:main .

The start the docker container running, I have had issues with the gateway exiting even though it's waiting for enter and I have been too lazy to fix it so instead I use tail -f /dev/null to keep the docker image running constantly:
docker run -d yarongmsft/hackfest:main tail -f /dev/null

Then find out the container ID:
docker ps

Then open a bash shell to the docker container:
docker exec -i -t [id] /bin/bash

Then navigate in the bash shell to:
cd /usr/src/app/iot-edge/build/samples/dotnet_core_module_sample

And then run the gateway:
./dotnet_core_module_sample "/usr/src/app/iot-edge/samples/dotnet_core_managed_gateway/dotnet_core_managed_gateway_lin.json"