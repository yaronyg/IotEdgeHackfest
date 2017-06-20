# IotEdgeHackfest
Playing with .net core on IoT Edge and looking at perf issues

# Random notes
docker build -t yarongmsft/hackfest:main .  <--- Building the image

docker run -d yarongmsft/hackfest:main tail -f /dev/null <--- Lets us keep the image running in the background so we can interogate it

docker exec -i -t [id] /bin/bash <--- Opens a bash shell

# How I created the HelloWorld test module
Sad to say the only way I could figure out how to make it work was to copy the PrinterModule and then do a search for 'PrinterModule' in all the files and replace them. And then manually change the file names from PrinterModule to HelloWorld. I wanted to use the dotnet tool but I ran into issues because my machine has dotnet core 2.0 installed and it won't create older project files.