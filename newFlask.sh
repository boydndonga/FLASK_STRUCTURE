#!/bin/sh

# Creating new app


# Initializing  git
git init
touch .gitignore
touch README.md

cat >> .gitignore << EOF

virtual/
*.pyc
start.sh

EOF


# Creating Root folders
mkdir app tests
touch config.py manage.py

# populating config file
cat >> config.py << EOF
class Config:
    pass

class ProdConfig(Config):
    pass

class DevConfig(Config):
    DEBUG = True

config_options ={"production":ProdConfig,"default":DevConfig}

EOF

# Creating manage file
cat >> manage.py << EOF

from flask_script import Manager,Server
from app import create_app,db

app = create_app('default')

manager = Manager(app)

manager.add_command('server', Server)

if __name__ == '__main__':
    manager.run()

EOF

# Creating application Folder
cd app
mkdir static templates static/css
touch __init__.py models.py

# Adding information to __init__.py
cat >> __init__.py << EOF

from flask import Flask
from config import config_options
from flask_bootstrap import Bootstrap
from flask_sqlalchemy import SQLAlchemy


bootstrap = Bootstrap()
db = SQLAlchemy()

def create_app(config_state):
    app = Flask(__name__)
    app.config.from_object(config_options[config_state])


    bootstrap.init_app(app)
    db.init_app(app)

    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)

    return app
EOF

# Creating main blueprint
mkdir main
cd main
# Creating main files
touch __init__.py views.py error.py

# Creating blueprint data
cat >> __init__.py << EOF

from flask import Blueprint
main = Blueprint('main',__name__)

from . import views

EOF


# Creating index view
cat >> views.py << EOF
from . import main

@main.route('/')
def index():
    return '<h1> Hello World </h1>'

EOF


# Creating virtual file
cd ../../

# Creating tests init file

touch tests/__init__.py

# Creating lauch file
touch start.sh

cat >> start.sh << EOF
python3.6 manage.py server
EOF

# making launch file executable
chmod a+x start.sh

# Creating virtual environment
python3.6 -m venv virtual

# Activate virtual environment
source virtual/bin/activate

# Installing dependencies
pip install flask
pip install flask-script
pip install flask-bootstrap
pip install gunicorn
pip install flask-wtf
pip install flask-sqlalchemy

pip freeze > requirements.txt


# Getting requirements
pip freeze > requirements.txt

# Creating procfile
touch Procfile

# Configuring procfile
cat >> Procfile << EOF
web: gunicorn manage:app
EOF

# Creating initial commit
git add . && git commit -m "Initial Commit"

# Open atom
atom .
