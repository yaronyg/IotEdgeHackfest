# IotEdgeHackfest
Playing with .net core on IoT Edge and looking at perf issues

These instructions are really just meant for throwing together debug builds and playing around.

# Running on Windows
## Setup
1. Install 32-bit version of the SDK at https://github.com/dotnet/core/blob/master/release-notes/download-archives/1.1.1-download.md
 1. We are using the 32 bit version because IoT Edge defaults to that. We can change this by calling tools/build.cmd with the -platform argument or edit the build-platform variable in build.cmd (to either Win32 or x64).
1. Setup the dev box per https://github.com/Azure/iot-edge/blob/master/doc/devbox_setup.md#set-up-a-windows-development-environment.
1. Fork https://github.com/yaronyg/iot-edge on github (so you can save your changes) and then clone your fork locally
1. Open a Visual Studio Command Prompt (Start -> Developer Command Prompt for Visual Studio 2017)
1. Navigate to iot-edge\tools
1. Run 'build.cmd --enable-dotnet-core-binding'
## Adding a new module
1. Open a terminal (doesn't have to be VS command prompt)
1. Go to iot-edge\tools
1. Run 'managed_module_projects.cmd --new Foo'
 1. Foo is to be replaced with the name of the project. It's best to just use something short and don't include the world Module as the system will append that where appropriate.

At this point the module now exists. But if you want it to be called by the gateway then you hae to edit iot-edge\samples\dotnet_core_managed_gateway\dotnet_core_managed_gateway_win.json for Windows and the lin version for Docker.

If you are using Visual Studio 2017 then you can just open the sln (iot-edge\bindings\dotnetcore\dotnet-core-binding\dotnet-core-binding.sln). Your module will be one of the projects listed in the project explorer.

If you are using VS Code then open iot-edge and find your module under iot-edge\samples\dotnet_core_module_sample\modules. If you open a cs file then set the project to dotnet-core-binding.sln.
## Removing a module
1. Open a terminal
1. Go to iot-edge\tools
1. Run 'managed_module_projects.cmd --delete Foo'

Note that this will delete all the source files from the modules directory.

Note that this will not delete any values in dotnet_core_managed_gateway_win/lin.json.

Running delete while Visual Studio has the solution open will cause the module's directory to be recreated but just with Visual Studio contents. However the existence of the directory will prevent --new from working so please make sure to manually go in an delete it or close the solution in Visual Studio before using delete.
## Building and running
1. Open a terminal
1. Go to iot-edge\tools
1. Run 'managed_module_projects.cmd --buildRun'
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

    ./dotnet_core_module_sample /usr/src/app/iot-edge/samples/dotnet_core_managed_gateway/dotnet_core_managed_gateway_lin.json

# APPENDIX
## Adding a module
These are the original instructions for adding a new module to IoT Edge. I'm keeping them because they work with the original GIT repo. 

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
