virtualenv -p `which python3` venv
source venv/bin/activate
pip install -r requirements.txt
python setup.py develop
python rest_api_demo/app.py
