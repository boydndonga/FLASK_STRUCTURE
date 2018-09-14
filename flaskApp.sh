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
touch config.py manage.py start.sh

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

echo "do you want to create db and shell context? [y/n]"
read CONTEXT

if [ "${CONTEXT^^}" == 'Y' ]; then
    manage_with_db_and_shell
else
    manage_without_db_and_shell
fi

# create init for tests
cd tests
touch __init__.py
cd ../

# Creating application Folder
cd app
mkdir static templates static/css main
touch __init__.py models.py main/__init__.py main/errors.py main/views.py

reusable_main_blueprint(){
cat >> main/__init__.py << EOF
from flask import Blueprint

main = Blueprint('main', __name__)

from . import views, error
EOF

cat >> main/views.py << EOF
from flask import render_template, request, redirect, url_for,abort
from . import main
from .. import db

@main.route('/')
def index():
    return '<h1> Hello World </h1>'
EOF

}
# Adding information to __init__.py

init_with_bootstrap(){

    reusable_main_blueprint

    cat >> __init__.py << EOF

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
}

init_with_db_authentication(){
    mkdir auth
    touch auth/views.py auth/__init__.py auth/forms.py

    reusable_main_blueprint
    
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

        from .auth import auth as auth_blueprint
        app.register_blueprint(auth_blueprint,url_prefix = '/authenticate')

        return app
EOF

cat >> auth/__init__.py << EOF
from flask import Blueprint

auth = Blueprint('auth',__name__)

from . import views,forms
EOF

cat >> auth/views.py << EOF
from . import auth
from .. import db
EOF
}