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
sudo apt list --upgradable
sudo apt-get install language-pack-en -y

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
gem install homesick
gem install eefgilm
gem install pry
gem install awesome_print
	
sh -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)"
wget -qO- https://cli-assets.heroku.com/install-ubuntu.sh | sh
echo "home sick!"
homesick clone cocohomie/dotfiles

rm /home/vagrant/.gemrc
rm /home/vagrant/.bashrc
rm /home/vagrant/.zshrc

homesick link
echo "cd /vagrant" >> /home/vagrant/.bashrc
echo "We are good to go!"

