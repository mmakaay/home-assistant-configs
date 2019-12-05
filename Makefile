all:
	chown -hR homeassistant:homeassistant .
	find . -type f -exec chmod 640 {} \;
	find ./bin -type f -exec chmod 750 {} \;
	find . -type d -exec chmod 750 {} \;
	chmod 600 secrets.yaml
	chmod 600 bravia.conf

install:
	# libxslt is used by FRITZ!Box integration, and not automatically installed
	# by Home Assistant version 0.101.2.
	sudo apt install libxslt1.1
	# required by the trend sensor platform.
	sudo apt-get install libatlas-base-dev
	# experimenting with bluetooth.
	sudo apt install bluetooth libbluetooth-dev
	# granting permissions to the app, so we don't have to run as root.
	sudo apt-get install libcap2-bin
	sudo setcap 'cap_net_bind_service+ep cap_net_raw,cap_net_admin+eip' `readlink -f \`which python3\``
	sudo setcap 'cap_net_raw+ep' `readlink -f \`which hcitool\``
	# PostgreSQL support for data storage
	sudo apt-get install postgresql-11 postgresql-server-dev-11
	echo "Please run:"
	echo "$ ./srv/homeassistant/bin/activate"
	echo "$ pip3 install psycopg2"

install_afvalbeheer:
	mkdir -p repos
	cd repos && /bin/rm -fR repos/Home-Assistant-Sensor-Afvalbeheer
	cd repos && git clone https://github.com/pippyn/Home-Assistant-Sensor-Afvalbeheer.git
	/bin/rm -fR custom_components/afvalbeheer
	cd custom_components && ln -s ../repos/Home-Assistant-Sensor-Afvalbeheer/custom_components/afvalbeheer

install_fold:
	cd repos && /bin/rm -fR lovelace-fold-entity-row
	cd repos && git clone https://github.com/thomasloven/lovelace-fold-entity-row
	/bin/rm -fR www/fold-entity-row.js
	cd www && cp ../repos/lovelace-fold-entity-row/fold-entity-row.js .

lovelace-dump:
	jq .data.config .storage/lovelace | python -c 'import sys, yaml, json; yaml.safe_dump(json.load(sys.stdin), sys.stdout, default_flow_style=False)' > lovelace-dump.yaml
