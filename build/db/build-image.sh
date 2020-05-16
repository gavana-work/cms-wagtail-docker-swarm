###########
#CLEANUP
###########

echo
echo
echo "[removing previous image build]"
echo
	docker image rm $(docker image ls | grep postgres-custom | awk '{print $3}') --force

###########
#DB BUILD
###########

echo
echo
echo "[building new image]"
echo
	docker build -t postgres-custom .