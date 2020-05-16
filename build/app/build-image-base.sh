###########
#CLEANUP
###########

echo
echo
echo "[removing previous image builds]"
echo
	docker image rm $(docker images | grep "<none>" | awk '{print $3}') --force
	docker image rm $(docker images | grep wagtail | awk '{print $3}') --force
	docker image rm $(docker images | grep base | awk '{print $3}') --force

###########
#BUILD
###########

echo
echo
echo "[building new base image]"
echo
	docker build -t app-base .