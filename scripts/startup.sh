virtualenv -p `which python3` venv
source venv/bin/activate
pip install -r ../api/requirements.txt
python ../api/setup.py develop
python ../api/rest_api_demo/app.py
