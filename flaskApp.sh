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