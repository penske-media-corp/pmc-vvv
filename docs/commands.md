# Commands
Before running the commands below, make sure you add the `vvv-local/provision/utilities/pmc/bin` directory to the `$PATH` and a variable called `VVV_INSTANCE_DIR` which contains the path to `vvv-local`
You can set it up as follows:
Edit the bashrc file. You can use any editor you want. The example uses *nano*
	```
	nano ~/.bashrc
	```

At the end of this file, put your new directory that you wish to permanently add to $PATH and also add the new Variable.
To find the path to the bin directory, run `pwd` inside that directory and copy the path.

    VVV_INSTANCE_DIR="PATH_TO_THE_UTILITIES_PMC_BIN_DIRECTORY"
    export PATH="$PATH:$VVV_INSTANCE_DIR/provision/utilities/pmc/bin"
Save your changes and exit the file. Afterwards, execute the following command to make the changes take effect in your current session. Alternative, you can log out or reboot the system.

	```
	source ~/.bashrc
	```
That is all that has to be done.
You can check $PATH to see if the path you set has been added correctly. 
You can also check VVV_INSTANCE_DIR variable

	```
	echo $PATH
	echo $VVV_INSTANCE_DIR
	```

## List of Commands

## `update-repos`

 To run this command, you must be in the wp-content directory of the site. This command will update the following directories:
 - mu-plugins
 - plugins
 - pmc-plugins
 - pmc-core-v2
 - pmc-themename-year

Each directory will only be updated if the branch is master and there are no changes in any files otherwise it will not update the directory. So make sure to checkout to master and have no changes in the file.

## `vcd`

This command will ssh into the VVV Shell to the folder from where you have run this command. This command requires the VVV to be running.

## `wp`

This command is to run the wp-cli commands in the shell right from the theme directory. This command requires the VVV to be running.
Example:
	```
	wp cron event list
	```
## `xdebug`

This command is to turn xdebug on or off. This command requires the VVV to be running.
Example:
	```
	xdebug on
	xdebug off
	```