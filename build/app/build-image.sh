###########
#CLEANUP
###########

echo
echo
echo "[removing previous image builds]"
echo
	echo "[<none>]"
	docker image rm $(docker images | grep "<none>" | awk '{print $3}') --force
	echo "[app]"
	docker image rm $(docker images | grep wagtail | awk '{print $3}') --force

###########
#APP BUILD
###########

echo
echo
echo "[building new app base image]"
echo
	cd code-base
	docker build -t app-base .

echo
echo
echo "[building new app image]"
echo
	docker build -t wagtail-custom .