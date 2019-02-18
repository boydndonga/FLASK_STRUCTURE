#!/usr/bin/env bash


# Creating new app


# Initializing  git
git init
touch .gitignore
cat >> .gitignore << EOF

# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]
*$py.class
instance


start.sh

# C extensions
*.so

# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# PyInstaller
#  Usually these files are written by a python script from a template
#  before PyInstaller builds the exe, so as to inject date/other infos into it.
*.manifest
*.spec

# Installer logs
pip-log.txt
pip-delete-this-directory.txt

# Unit test / coverage reports
htmlcov/
.tox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
.hypothesis/
.pytest_cache/

# Translations
*.mo
*.pot

# Django stuff:
*.log
local_settings.py
db.sqlite3

# Flask stuff:
instance/
.webassets-cache

# Scrapy stuff:
.scrapy

# Sphinx documentation
docs/_build/

# PyBuilder
target/

# Jupyter Notebook
.ipynb_checkpoints

# pyenv
.python-version

# celery beat schedule file
celerybeat-schedule

# SageMath parsed files
*.sage.py

# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/
.idea/
virt/
.virt/

# vscode
.vscode/

# Spyder project settings
.spyderproject
.spyproject

# Rope project settings
.ropeproject

# mkdocs documentation
/site

# mypy
.mypy_cache/


EOF

# Initializing Readme
echo "should i create a README? y/n"
read ANSWER

if [ "${ANSWER^^}" == 'Y' ]; then
    touch README.md
    echo "created README"
else
    echo "README not created"
fi

# Creating Root folders
mkdir app tests
touch config.py manage.py start.sh requirements.txt

# make script executable
chmod +x start.sh

# populating config file
cat >> config.py << EOF

class Config:
    pass

class ProdConfig(Config):
    pass

class TestConfig(Config):
    pass

class DevConfig(Config):
    DEBUG = True

config_options ={"production":ProdConfig,"default":DevConfig,"testing":TestConfig}

EOF

# Creating start.sh content
cat >> start.sh << EOF

python3.6 manage.py server

EOF


# Creating manage file

manage_without_db_and_shell(){

cat >> manage.py << EOF
from flask_script import Manager,Server
from app import create_app

app = create_app('default')

manager = Manager(app)

manager.add_command('server', Server)

if __name__ == '__main__':
    manager.run()
EOF
}

manage_with_db_and_shell(){
cat >> manage.py << EOF
import unittest
from flask_script import Manager,Server
from app import create_app,db
from  flask_migrate import Migrate, MigrateCommand

app = create_app('default')

manager = Manager(app)
migrate = Migrate(app,db)
manager.add_command('server', Server)
manager.add_command('db',MigrateCommand)

@manager.command
def test():
    """Run the unit tests."""
    tests = unittest.TestLoader().discover('tests')
    unittest.TextTestRunner(verbosity=2).run(tests)


@manager.shell
def make_shell_context():
    return dict(app = app,db = db)


if __name__ == '__main__':
    manager.run()

EOF

}


# create init for tests
cd tests
touch __init__.py
cd ../

# Creating application Folder
#cd app
mkdir app/static app/templates app/static/css app/main
touch app/__init__.py app/models.py app/main/__init__.py app/main/errors.py app/main/views.py app/main/forms.py

reusable_main_blueprint(){
cat >> app/main/__init__.py << EOF
from flask import Blueprint

main = Blueprint('main', __name__)

from . import views, errors
EOF

cat >> app/main/views.py << EOF
from flask import render_template, request, redirect, url_for,abort
from . import main
from .. import db

@main.route('/')
def index():
    return '<h1> Hello World </h1>'
EOF

cat >> app/main/forms.py << EOF
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField
from wtforms.validators import Required
EOF

}


# Adding information to __init__.py

init_with_bootstrap(){

reusable_main_blueprint

cat >> app/__init__.py << EOF

from flask import Flask
from config import config_options
from flask_bootstrap import Bootstrap
from flask_sqlalchemy import SQLAlchemy


bootstrap = Bootstrap()

def create_app(config_state):
    app = Flask(__name__)
    app.config.from_object(config_options[config_state])


    bootstrap.init_app(app)

    from .main import main as main_blueprint
    app.register_blueprint(main_blueprint)


    return app
EOF
}

init_with_db(){

reusable_main_blueprint

cat >> app/__init__.py << EOF

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
}

init_with_db_authentication(){
mkdir app/auth
touch app/auth/views.py app/auth/__init__.py app/auth/forms.py

reusable_main_blueprint

cat >> app/__init__.py << EOF

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

    from .auth import auth as auth_blueprint
    app.register_blueprint(auth_blueprint,url_prefix = '/authenticate')

    return app
EOF

cat >> app/auth/__init__.py << EOF
from flask import Blueprint

auth = Blueprint('auth',__name__)

from . import views,forms
EOF

cat >> app/auth/views.py << EOF
from . import auth
from .. import db
EOF

cat >> app/auth/forms.py << EOF
from flask_wtf import FlaskForm
from wtforms import StringField, TextAreaField, SubmitField, PasswordField
from wtforms.validators import Required
EOF

}

PS3='Please enter your choice editor to launch: '
options=("create with bootstrap only" "create with: bootstrap and db" "create with: bootstrap,db,authentication" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "create with bootstrap only")
            echo "initializing app with bootstrap"
            init_with_bootstrap
            manage_without_db_and_shell
            break
            ;;
        "create with: bootstrap and db")
            echo "creating main blueprint with db"
            init_with_db
            manage_with_db_and_shell
            break
            ;;
        "create with: bootstrap,db,authentication")
            echo "creating main and auth blueprints with db"
            init_with_db_authentication
            manage_with_db_and_shell
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done


# Creating virtual environment
python3 -m venv virtual

# Activate virtual environment
source virtual/bin/activate

# Installing dependencies
pip install flask
pip install flask-script
pip install flask-bootstrap
pip install gunicorn
pip install flask-wtf
pip install flask-sqlalchemy
pip install Flask-Migrate
pip install psycopg2

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


PS3='Please enter your choice editor to launch from above options: '
options=("Atom" "vscode" "pycharm" "Quit")
select opt in "${options[@]}"
do
    case $opt in
        "Atom")
            echo "opening atom"
            atom . &
            break
            ;;
        "vscode")
            echo " Opening Vscode"
            code . &
            break
            ;;
        "pycharm")
            echo "opening pycharm"
            pycharm.sh . &
            break
            ;;
        "Quit")
            break
            ;;
        *) echo "invalid option $REPLY";;
    esac
done