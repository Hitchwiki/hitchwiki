echo ""
echo "INSTALLING DOCKER ..."

#Avoid error "modprobe: FATAL: Module aufs not found" while installing docker
sudo apt-get -qq update
sudo apt-get install -y linux-image-extra-$(uname -r)
sudo modprobe aufs

#Get Docker
wget -qO- https://get.docker.com/ | sh

echo ""
echo "PULLING DISCOURSE ..."

#Get Discourse

sudo mkdir /var/discourse
sudo git clone https://github.com/discourse/discourse_docker.git /var/discourse
echo ""
echo "SETTING UP APACHE ..."

#Setup apache
sudo cp /var/www/scripts/configs/discourse.dev.conf /etc/apache2/sites-available/
sudo a2enmod -q proxy
sudo a2enmod -q proxy_http  
cd /etc/apache2/sites-available/
sudo a2ensite -q discourse.dev
sudo sudo /etc/init.d/apache2 restart

echo ""
echo "COPYING CONFIG FILE ..."

#Copy the config file for discourse
sudo cp /var/www/scripts/configs/discourse_dev.yaml /var/discourse/containers/app.yml

echo ""
echo "BUILDING DISCOURSE ..."

#Build Discourse
sudo /var/discourse/launcher rebuild app

echo ""
echo "DONE WITH INSTALLING DISCOURSE!"