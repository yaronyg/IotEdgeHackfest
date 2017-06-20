# IotEdgeHackfest
Playing with .net core on IoT Edge and looking at perf issues

# Random notes
docker build -t yarongmsft/hackfest:main .  <--- Building the image

docker run -d yarongmsft/hackfest:main tail -f /dev/null <--- Lets us keep the image running in the background so we can interogate it

docker exec -i -t [id] /bin/bash <--- Opens a bash shell

# How I created the HelloWorld test module
I created a new project in dotnet-core-binding as .NET Standard Class Library and added it into Samples/dotnet_core_module_sample/modules. I changed the Class1.cs filename to my module name just to be consistent. I then right click on the new project and hit properties. I set target framework to .NETStandard1.3. Then I right clicked on Dependencies (under the new project) in the project explorer and selected Add Reference and then Projects->Solution and clicked on 'Microsoft.Azure.Devices.Gateway'. Then I went to dotnet_core_managed_gateway, right clicked on Dependencies->Add Reference and under Projects->Solution clicked on my new module. Then I went to build_dotnet_core.cmd and added my new module to projects-to-build and the same for build_dotnet_core.sh. Then it's off to dotnet_core_managed_gateway_win.json and dotnet_core_managed_gateway_lin.json to add the new service as a module and set up any necessary links. Next up it's Ciot-edge\MakeList.txt where I have to add an entry for my module of the form dotnet_core_*_dll, see dotnet_core_printer_dll for an example. Followed by iot-edge\samples\dotnet_core_module_sample\CMakeLists.txt where we add an install_Binaries line refering to the previous make rule. Again, check out dotnet_core_printer_module_dll for an example.

# Running on Windows
To set up the same environment as we are using on Docker on Linux I installed "1.1.1 with SDK 1.0.1" released on 2017/03/07 from https://github.com/dotnet/core/blob/master/release-notes/download-archives/1.1.1-download.md. I used SDK Installer for Windows, 32-bit. We have to use 32 bit because that is the default. We could use 64 bit, to do that go to tools/build.cmd and either submit the --platform argument when calling it or one can set build-platform on line 24 (or so) from Win32 to x64. But I'm going to stick with 32 since it really doesn't matter for the moment.

We also need to setup the dev box per https://github.com/Azure/iot-edge/blob/master/doc/devbox_setup.md#set-up-a-windows-development-environment.

Now open a Visual Studio Command Prompt (Start -> Developer Command Prompt for Visual Studio 2017)

Then I ran /Iot-Edge/tools/build_dotnet_core.cmd and then 'build.cmd --enable-dotnet-core-binding'

Then it off to iot-edge\build\samples\dotnet_core_module_sample\Debug\dotnet_core_module_sample ..\..\..\..\samples\dotnet_core_managed_gateway\dotnet_core_managed_gateway_win.json
