# IotEdgeHackfest
Playing with .net core on IoT Edge and looking at perf issues

# Random notes
docker build -t yarongmsft/hackfest:main .  <--- Building the image

docker run -d yarongmsft/hackfest:main tail -f /dev/null <--- Lets us keep the image running in the background so we can interogate it

docker exec -i -t [id] /bin/bash <--- Opens a bash shell