requirements-on-mac:	 	## Install requirements on MacOs using Docker
	@docker run -it --rm --name python36_certbot -v "${PYTHON_CODE_FOLDER}:/python_code" python:3.6.8 pip install -r /python_code/requirements.txt -t /python_code/

requirements: 			## Install requirements on Linux
	@pip3 install virtualenv \
		&& python3.6 -m virtualenv certbot-env-temp \
		&& source certbot-env-temp/bin/activate \
		&& pip install -r python_code/requirements.txt -t python_code/ \
		&& deactivate \
		&& rm -rf certbot-env-temp

help: 
	@grep -E '^[a-zA-Z0-9_/-]+:.*?## .*$$' Makefile | sed -e s/://

.DEFAULT_GOAL  := help