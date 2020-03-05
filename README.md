# FLASK_STRUCTURE
This is a script for every lazy developer or any other that seeks to save time creating the whole flask structure.

## SETUP
### Prerequisites (not required, just good to have)
1. Python3
2. Virtualenv
3. Git

### Run on your terminal where you want the project to be created:
Wget
```shell
bash -c "$(wget -O - https://raw.githubusercontent.com/newtonkiragu/FLASK_STRUCTURE/master/flaskApp.sh)"
```
Curl
```shell
sh -c "$(curl -fsSL https://raw.githubusercontent.com/newtonkiragu/FLASK_STRUCTURE/master/flaskApp.sh)"
```
That's it.
### Options:
| *Option* | *Output* 
--- | --- 
Should I create a README? | creates a README.md file
create with bootstrap only | initialize bootstrap for use in the app
create with: bootstrap and db | initialize bootstrap and SQLAlchemy in your app
create with: bootstrap,db,authentication | initialize bootstrap, SQLAlchemy and auth blueprint in your app

### Disclaimer
 - This script creates flask using the `blueprints` structure.
 - This script doesnt create a database for you, it just installs the necessary packages required to integrate a db seamlessly in the app.

![Sample Structure](flaskStructure.png)
