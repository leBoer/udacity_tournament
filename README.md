#Description
This is a Python module using the PostgreSQL database that keeps track of players and matches in a game tournament.
- **tournament.py** holds the Python code that acts on the database. I've tried to include as little python code as possible, and do most of the work through views in the tournament.sql file
- **tournament.sql** builds the database with two tables, and a set of views to reduce the Python code as much as possible. I've preloaded eight players, and two rounds of matches that can be un-commented of testing purposes, though they are not necessary to pass the test.
- **tournament_test.py** is a file provided by Udacity that tests the python code and the database. I have not modified this.


#How to run
- Set up a Virtual Machine with VirtualBox and Vagrant. Use the [configuration from this location](https://d17h27t6h515a5.cloudfront.net/topher/2016/December/58488015_fsnd-virtual-machine/fsnd-virtual-machine.zip).
- Download the files in this repo, and save them to the shared vagrant folder
- Using your preferred terminal (I recommend Git Bash for Windows), navigate to the shared vagrant folder
- Start the VM by typing "vagrant up"
- Log into the VM by typing "vagrant ssh"
- Import the databse schema using "psql" application by typing:
	- psql
	- \i tournament.sql
	- \q
- Execute the test module by invoking the python script: "python tournament_test.py"