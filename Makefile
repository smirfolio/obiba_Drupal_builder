SHELL := /bin/bash
# Obiba Drupal Builder Script

#apache
WF=/var/www/html
#mysql
dbu=root
dbp=1234
dbn=drupal_obiba
#Drupal
DV=7.56
DF=drupal-release
DAdm=administrator
Spass=password
#obiba
MV=7.x-32.2
AV=7.x-2.4
BV=7.x-4.4

build-obiba: remove_old_obiba download-drupal mysql-create site-install obiba-dl-dependecies obiba-en-dependecies obiba-js-dependecies obiba-composer-conf obiba-settings obiba-permission

remove_old_obiba: 
	pushd $(WF) && sudo rm -rf $(DF) && popd

download-drupal:
	pushd $(WF) && sudo drush dl drupal-$(DV) && sudo mv drupal-$(DV) $(DF)  && popd

mysql-create:
	mysql -u $(dbu) --password=$(dbp) -e "drop database if exists $(dbn); create database $(dbn);"

site-install: 
	pushd $(WF)/$(DF) && sudo drush site-install standard --account-name=$(DAdm) --account-pass=$(Spass) --db-url=mysql://$(dbu):$(dbp)@localhost/$(dbn) -y popd

obiba-dl-dependecies:
	pushd $(WF)/$(DF) && sudo drush dl -y bootstrap obiba_bootstrap-$(BV) obiba_mica-$(MV) obiba_agate-$(AV)  autologout && popd

obiba-en-dependecies:
	pushd $(WF)/$(DF) && sudo drush en -y bootstrap obiba_bootstrap obiba_mica obiba_agate  autologout && popd

obiba-clear-cache:
	pushd $(WF)/$(DF) && sudo drush cc all && popd

obiba-js-dependecies:
	pushd $(WF)/$(DF) &&  sudo drush download-mica-dependencies && popd

obiba-composer-conf:
	pushd $(WF)/$(DF) && sudo drush composer-json-rebuild && popd && \
	pushd $(WF)/$(DF)/sites/default/files/composer && \
	sudo composer update && \
	sudo composer dump-autoload -o && popd && \
	pushd  $(WF)/$(DF) && \
	popd

obiba-settings:
	pushd $(WF)/$(DF) drush vset -y --format=string jquery_update_jquery_version 1.10 && \
	pushd $(WF)/$(DF) drush vset -y --format=string jquery_update_jquery_admin_version 1.10 && \
	pushd $(WF)/$(DF) drush vset -y autologout_redirect_url "<front>" && \
	pushd $(WF)/$(DF) drush vset -y autologout_no_dialog TRUE && \
	popd

obiba-permission:
	sudo chown -R www-data: $(WF)/$(DF) && \
	sudo chown -R $(USER): ~/.composer && \
	sudo chown -R $(USER): ~/.drush 






