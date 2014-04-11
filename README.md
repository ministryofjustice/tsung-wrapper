# tsung-wrapper



This project enables the creation of complex XML files for load testing using Tsung, from a series of 
yaml configuration files.  The tool can be used to just produce the XML file, or actually run the tsung session.


## Configuration Files

Configuration files are located in the /config directory (for testing, they are located in /spec/config).
The config directory contains the dtd file to be used, plus three folders: 

*  environments
*  sessions
*  snippets

 
## Environments Folder
There should be a configuration file for each environment that you intend to run, e.g.
 
 * development.yml
 * test.yml
 * staging.yml
 * production.yml
 
Each environment file contains global variables that will be used when building the Tsung XML configuration file.  A typical example might be:



		server_host: test_server_host
		base_url: http://test_base_url.com
		maxusers: 40
		server_port: 8080
		http_version: 1.1

		arrivalphases:
		  - name: Average Load
		    sequence: 1
		    duration: 10
		    duration_unit: minute
		    arrival_interval: 30
		    arrival_interval_unit: second
		  - name: High Load
		    sequence: 2
		    duration: 10
		    duration_unit: minute
		    arrival_interval: 10
		    arrival_interval_unit: second
		  - name: Very High Load
		    sequence: 3
		    duration: 5
		    duration_unit: minute
		    arrival_interval: 2
		    arrival_interval_unit: second   

		user_agents:
		  - name: Linux Firefox
		    user_agent_string: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21"
		    probability: 80
		  - name: Windows Firefox
		    user_agent_string: "Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4"
		    probability: 20

All of the above elements must be present.



## Sessions Folder

This folder contains yaml files that describe the sessions that you want to run.

Basically, they are just simple containers for an array of dynamic variables that are used, and snippets that will be included into the XML file, e.g.




		session:
			dynvars:
		    username: random_str_12
		    userid: random_number
		    today: erlang_function
		  snippets:
		    - hit_landing_page
		    - hit_register_page

In the above example, three dynamic variables are declared (username, userid, today), and the definition is taken from the follwoing files:

* config/dynvars/random_str_12.yml, 
* config/dynvars/random_number.yml
* config/dynvars/erlang_funtion.yml

The name of the session is taken from the name of the file, and will be included as a comment in the XML.



## Snippets Folder

This folder contains the snippets - details of requests that are to be made, and will be included in a session.

And example is hit_register_page.yml, inluded as the second snippet in the session file described above.

	request:
	  name: Hit Register Page
	  url: 'user/register'
	  http_method: GET

The name of the snippet as defined in the file will be included into the XML file as acommen.

The url will be appended to the base_url defined in the environment configuration.


## Dynamic variable definition and substitution

Dynamic variables can be defined in special snippets located in the congig/dynvars folder.
They can be included into a session under the dynvars section, specifying the name of the dynamic variable snippet, and the namne to 
be given to the variable so that it can later be referred to in snippets, e.g

		session:
			dynvars:
				username: randomstr12
				userid: random_num6

		  snippets:
		    - hit_landing_page
		    - hit_register_page

The above session delares that there are two dynamic variables used, the one defined in config/dynvars/randomstr12.yml and will be 
assigned the name 'username', and the one defined in config/dynvars/randomnum6.yml and will be assigned the name userid.

These dynamic variables can be referred to in subsequent snippets as %%_username%% and %%_userid%%.

### Types of dynamic variables

There are three kinds of dynamic variables that can be defined:
	* random string
	* random number
	* result of an Erlan function

The dynamic variables are defined in small yaml files in the dynvars section.  They can then be refered to in the sessions yaml files and given 
a name for subsequent referencingin the snippets.

#### Defining a random string

		dynvar:
			type: random_string
			length: 10
			

As may be guessed, this will generate a 10-byte random string.

#### Defining a random number

		dynvar:
			type: random_number
			start: 1
			end:  500000
			

#### Defining an Erlang Function
	
Erlang functions can be used to generate output:

	dynvar:
		type: erlang
		code: datetime_str
		

	This will load the erlang fucntion defined in config/erlang/datetime_str.  Whenever you want to use this in a request, you can refer to it by its name, e.g. '%%_today%%'.

	


## Command line usage

    wrap [-e <environment>] -x|-r session_name

    -e run using the specified environment.  If not specified, 'development is assumed'.
    -x just produce the xml file to STDOUT
    -r pipe the output into tsung
    session_name - the name of the session to be executed.  There must be a file of this name with the extension .yml in the config directory.

    



