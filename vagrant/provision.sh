ANSIBLE_PATH="/vagrant/vagrant/ansible"
USER=$1

#temporarly rename gemset lock
mv /vagrant/.ruby-gemset /vagrant/ruby-gemset.tmp 2>/dev/null

#install ansible
apt-get install -y software-properties-common \
  && apt-add-repository -y ppa:ansible/ansible \
  && apt-get update \
  && apt-get install -y ansible \
  && cd /vagrant/vagrant/ansible \
  && ansible-galaxy install -r requirements.galaxy --force

# #create rvm group if it doesn't exist
getent group rvm || groupadd rvm
# #add vagrant user to rvm group to have correct permissions
usermod -a -G rvm vagrant

# #run playbook
sudo -H -u vagrant bash -c "ansible-playbook -i $ANSIBLE_PATH/inventory --extra-vars host_os_user=$USER $ANSIBLE_PATH/app.yml"

#revert gemlock changes
mv /vagrant/ruby-gemset.tmp /vagrant/.ruby-gemset 2>/dev/null

exit 0
