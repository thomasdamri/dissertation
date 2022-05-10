# TeamPlayerPlus
TeamPlayerPlus is an online application built to provide students with an group environment, specialized in curating fair teamwork.
Students can create tasks, contribute to meetings, and analyze project statistics.
Once a project is finished, students are assigned online peer assessments, used to determine an individialised rating.
From their ratings, individual weightings are generated which can then be applied to grades. The algorithm used to generate the individual weightings is identical to the [one used in WebPA](http://webpaproject.com/webpa_wiki/index.php/The_Scoring_Algorithm). 

## Installation Instructions (Development Environment)
- Clone this repo to a new folder
- Install mysql for your operating system (eg. on Ubuntu 20.04 do `sudo apt-get install mysql-client libmysqlclient-dev`)
- Create a user in the MySQL terminal for the server to use
- Modify the file `config/database.yml` to use the user and password you just created
- Install Ruby (I'm using 2.6.6, but other versions may work. Use of RVM or rbenv may make installation easier)
- Install a relatively recent version of NodeJS (I'm using 12.18.4, but most will work)
- Install Yarn (I'm using 1.22.5, but most will work)
- You will also need an epiGenesys gem server logon.
- Open a terminal inside this repo's root folder
- Run `bundler install` while on the university VPN
- Run `yarn install` to get Javascript dependencies
- Open `db/seeds.rb` and create yourself a user to log in with by copying the line with username `acc17dp` and changing the details as appropriate
- Run `rails db:setup` to initialise the database
- Run `rails s` to start the server
- Go to localhost:3000 to access the site
- You will need to be on the VPN in order to log in

### Attributions
This project used Material Design Icons from Google, licensed under the Apache License Version 2.
