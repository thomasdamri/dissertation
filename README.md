# TeamAssessment

## Installation Instructions
These instructions were written for Ubuntu 20.04, but any recent version of Ubuntu should work
- Install the mysql packages from apt using `sudo apt-get install mysql-client libmysqlclient-dev`
- Install Ruby (I'm using 2.6.6, but other versions may work. Use of RVM or rbenv may make installation easier)
- Install a relatively recent version of NodeJS (I'm using 12.18.4, but most will work)
- Install Yarn (I'm using 1.22.5, but most will work)
- You will also need an epiGenesys gem server logon.
- Clone the repo to a new folder
- Open a terminal in this new folder
- Run `bundler install` while on the university VPN
- Run `yarn install` to get Javascript dependencies
- Run `rails db:setup` to initialise the database
- Run `rails s` to start the server
- Go to localhost:3000 to access the site
- You will need to be on the VPN in order to log in
