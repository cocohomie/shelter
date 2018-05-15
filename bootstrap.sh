#!/bin/bash

if
  [[ "${USER:-}" == "root" ]]
then
  echo "This script works only with normal user, it wont work with root, please log in as normal user and try again." >&2
  exit 1
fi

set -e

curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash -
sudo add-apt-repository ppa:jonathonf/vim -y
echo "Updates packages. Asks for your password."
sudo apt-get update -y

echo "Installs packages. Give your password when asked."
sudo apt-get --ignore-missing install build-essential direnv git-core curl openssl libssl-dev libcurl4-openssl-dev zlib1g zlib1g-dev libreadline-dev libreadline6 libreadline6-dev libyaml-dev libsqlite3-dev libsqlite3-0 sqlite3 libxml2-dev libxslt1-dev python-software-properties libffi-dev libgdm-dev libncurses5-dev automake autoconf libtool bison postgresql postgresql-contrib libpq-dev pgadmin3 libc6-dev nodejs git-flow -y
sudo apt-get dist-upgrade -y
sudo apt-get install git-flow -y
sudo apt-get install direnv -y
sudo apt list --upgradable
sudo apt-get install language-pack-en -y
sudo apt-get install ack-grep -y

# Create Role and login
sudo su postgres -c "psql -c \"CREATE ROLE vagrant SUPERUSER LOGIN PASSWORD 'vagrant'\" "

echo "Installs ImageMagick for image processing"
sudo apt-get install imagemagick --fix-missing -y

echo "Installs RVM (Ruby Version Manager) for handling Ruby installation"
gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
curl -sSL https://get.rvm.io | bash -s stable
source ~/.rvm/scripts/rvm

echo "Installs Ruby"
rvm install 2.5.1
rvm use 2.5.1 --default

echo "gem: --no-ri --no-rdoc" > ~/.gemrc
gem install bundler
gem install rails
gem install homesick
gem install eefgilm
gem install pry
gem install awesome_print
gem install annotate 
gem install mailcatcher

sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh

echo -e "\n- - - - - -\n"
echo -e "Now we are going to print some information to check that everything is done:\n\n"

echo -n "Should be rvm 1.29 or higher:         "
rvm --version
echo -n "Should be ruby 2.4.1 or higher:                "
ruby -v
echo -n "Should be Bundler 1.15 or higher:         "
bundler -v
echo -n "Should be Rails 5.1.3 or higher:         "
rails -v
echo -n "Should be NodeJS 6.11 or higher:         "
node -v
echo -n "Should be sqlite 3.11 or higher:         "
sqlite3 --version
echo -n "Should be ImageMagick 6.8.9 or higher:         "
convert --version
echo -n "Should be Heroku 6.13 or higher:            "
heroku --version
echo -e "\n- - - - - -\n"

echo "If the versions match, everything is installed correctly."

echo "home sick!"
homesick clone cocohomie/dotfiles
rm /home/vagrant/.gemrc
rm /home/vagrant/.bashrc
rm /home/vagrant/.zshrc

homesick link
echo "cd /vagrant" >> /home/vagrant/.bashrc


cd /vagrant

if [ ! -d "app/" ]; then
 rails new . --database postgresql
 mv database.yml.base config/database.yml
 bundle exec rails db:create
 bundle exec rails db:migrate
else
 echo "Setup the database"
 bundle exec rails db:create
 bundle exec rails db:schema:load
 bundle exec rails db:migrate
fi

#clean up repository
rm -rf .git 
git init .
git add .
git commit -am "iniial upload"

echo "We are good to go!"
