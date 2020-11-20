# TeamAssessment

## Installation Instructions
These instructions were written for Ubuntu 20.04, but any recent version of Ubuntu should work
- Install the mysql packages from apt using `sudo apt-get install mysql-client libmysqlclient-dev`
- Run `mysql -u root -p` and then enter your sudo password to log into mysql as the root user
    - If mysql does not accept this as your root password, follow [this guide](https://devanswers.co/how-to-reset-mysql-root-password-ubuntu/)
- Create the user by typing `CREATE USER 'team'@'localhost' IDENTIFIED BY '<enter password here>';`
- Grant the new user permissions `GRANT ALL PRIVILEGES ON *.* TO 'team'@'localhost';`
- Refresh privileges `FLUSH PRIVILEGES;`
- Quit mysql by typing `\q`
- Go to your home directory, set hidden files to viewable and open the file `.profile`
- At the bottom of this file, type `export team_db_password='<enter same password here>'`
- Restart your computer so that the new export variable takes effect
- Install Ruby (I'm using 2.6.6, but other versions may work. Use of RVM or rbenv may make installation easier)
- Install a relatively recent version of NodeJS (I'm using 12.18.4, but most will work)
- Install Yarn (I'm using 1.22.5, but most will work)
- You will also need an epiGenesys gem server logon.
- Clone the repo to a new folder
- Open a terminal in this new folder
- Ensure you are on the `demo` branch by doing `git checkout origin/demo`
- Run `bundler install` while on the university VPN
- Run `yarn install` to get Javascript dependencies
- Open `db/seeds.rb` and create yourself a user to log in with by copying the line with username `acc17dp` and changing the details as appropriate
- Run `rails db:setup` to initialise the database
- Run `rails s` to start the server
- Go to localhost:3000 to access the site
- You will need to be on the VPN in order to log in
