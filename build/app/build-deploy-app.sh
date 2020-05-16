###########
#CLEANUP
###########

echo
echo
echo "[removing previous image build]"
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
echo "[building new app image]"
echo
	docker build -t wagtail-custom .

###########
#DEPLOY APP
###########

echo
echo
echo "[deploying the stack]"
echo
	docker stack deploy blog -c ../../deploy/docker-compose.yml
	sleep 35

echo
echo
echo "[checking stack]"
echo
	docker stack ps blog

echo
echo
echo "[checking app std out]"
echo
	docker logs $(docker ps -a | grep wagtail | awk '{print $1}')