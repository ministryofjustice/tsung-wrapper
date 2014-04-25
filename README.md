# tsung-wrapper

Author: Stephen Richards <stephen.richards@digital.justice.gov.uk>


## Contents

* [Overview](#overview)
* [Dependencies](#dependencies)
* Running tsung-wrapper
	* Usage
	* Usage Examples
* Configuration Files
	* The environments folder
	* the load_profiles folder
	* the sessions folder 
	* the snippets folder
	* the dynvars folder
Development Server Confiurationa dn Tips for Creating Complex Sessions
	* Log file format
	* Clearing the access log before a run
	* Creaitng complex sessions


## Overview

This project enables the creation of complex XML files for load testing using Tsung, from a series of 
yaml configuration files.  The tool can be used to just produce the XML file, or actually run the tsung session, and the stats run to produce the graphs.


## Dependencies
* tsung - Donwload from http://tsung.erlang-projects.org/dist/, or on mac: 

	<code>brew install tsung</code>

* perl Template toolkit, which can be installed with:

	<code>cpan Template</cpan>



## Running tsung-wrapper

The tsung-wrapper suite is run in three distinct phases:

* Running the lib/wrap.rb executable to produce an xml file which will be used by tsung
to control the load testing
* Running tsung itself to send requests to the server in accordance with the instructions in the xml configuration file
* Running the stats program to produce the HTML reports and graphs.

All three of the steps above can be run using the lib/wrap.rb executable.

### Usage

    Usage: wrap [-e environment] [-l load_profile] [-v] [-s] -x|-r session_name
       wrap [-e environment] -c n

	Generate Tsung XML file for session <session_name>

    -e, --environment  ENV           Use specified environment (default: development)
    -x, --xml-out                    Generate XML config and write to STDOUT
    -r, --run-tsung                  Generate XML config and pipe into tsung
    -l, --load-profile LOAD_PROFILE  Use specific load profile
    -s, --generate-stats             Generate Stats (requires that -r option is set
    -v, --verbose                    Set verbose mode ON
    -c, --clean-log-dir HOURS        Clean log dir of directories created before N hours ago


### Usage examples

These commands should be run from the root folder of the tsung-wrapper directory.


* Use the "development.yml" environment confiifuration file, with load profile "heavy.ymnl" and the session file "full_run.yml" and just produce the xml file and pipe it to tmp/heavy_full_run.xml


	``ruby lib/wrap.rb -e development -l heavy -x full_run  > tmp/heavy_full_run.xml``

    
* Use the "dev_dump.yml" environment, "single_user.yml" load profile and session "full_run.yml" to produce the XMl file, run tsung using that file, and then generate the stats afterwards.

	``ruby lib/wrap.rb -e dev_dump -l single_user -rs full_run``
	
In the latter case above, the tsung log files will be written to a folder in ~/.tsung/log - the actual name given to the folder will be displayed on the console.   





## Configuration Files

Configuration files are located in the /config directory (for testing, they are located in /spec/config).  The contents of these files are what determines the contents of the XML file, which in turn determines how the load test is run.  The idea is that you have several standard config files, and you can pick and chooses between them to create whateve load testing session you want.

The config directory contains the dtd file to be used, plus six folders: 

*  __environments__<br/>
	describes the environment to run (host, log level, user agents, etc
*  __load_profiles__<br/>
	decsribes the load to use during the test.  This could be single user, used when developing a load test to see the user journey through the site, or a series of phases to progressively load the server
*  __sessions__<br/>
	gives a name to a session, which comprises of a series of requests, each request being detailed in a snippet
*  __snippets__<br/>
	each snippet is a single GET or POST request, with or without parameters
*  __matches__<br/>
	standardised tests that can be carried out on the response, and action taken depending on the result
*  __dynvars__<br/>
	The definition of dynamic variables which can be used in requests, eg. to generate a random string to use as a username.


The following sections look at each of the configuration files in more detail.


### The environments Folder
There should be a configuration file for each environment that you intend to run, e.g.
 
 * development.yml
 * test.yml
 * staging.yml
 * production.yml
 
Each environment file contains global variables that will be used when building the Tsung XML configuration file.  A typical example might be:



		server_host: test_server_host
		base_url: http://test_base_url.com
		maxusers: 9000
		server_port: 80
		http_version: 1.1
		load_profile: heavy
		dumptraffic: protocol
		loglevel: debug
		default_thinktime: 4
		default_matches:
		  - abort_unless_success_or_redirect

		user_agents:
		  - name: Linux Firefox
		    user_agent_string: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21"
		    probability: 80
		  - name: Windows Firefox
		    user_agent_string: "Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4"
		    probability: 20

All of the above elements except default_thinktime and default_matches must be present.

Most of the elements are self explanatory, but the following need a bit more explanation:

* __load_profile__: which load profile to use.  This can be overridden by the command line swith -l at runtime.
*  __dumptraffic__: this can be one of the follwing values:
	* true: dump the entire request and response to tsung.dump
	* false: do not dump anything
	* light: dump the first 44 bytes of the response to tsung.dump
	* protocol: dump the details of the request and response status to tsung.dump
	
See http://tsung.erlang-projects.org/user_manual/conf-file.html for details.
	
	The most useful setting is protocol.
* loglevel: determines what gets logged to the tsung_cxontroller_<machine_name>.log.  Possible values are: 
	* emergency 
	* critical
	* error
	* warning
	* notice
	* info
	* debug 	

See http://tsung.erlang-projects.org/user_manual/conf-file.html for details.  




### The load_profiles folder

The files in this folder specify various load profiles.  The default load profile for each environment is specified in the 
environment file, but may be overridden on the command line with the -l command line switch.

A typical load_profile looks like this:

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

As you can see, each load profile is a colleciton of 1 or more "arrival phases".  Most arrival phases are like the one above, specifying a duration and the interval between new sessions being started.  However the syntax below can also be used if  you want to control the total number of users.  The configuration below specifies just one user session, which can be very useful in debugging when setting up a new session to use.

		arrivalphases:
	  	  - name: Single User
	    	sequence: 1
	    	duration: 6
	    	duration_unit: second
	    	max_users: 1
	    	arrival_rate: 5
	    	arrival_rate_unit: second


### The sessions Folder

This folder contains yaml files that describe the sessions that you want to run.

There are two main bit of information that the session file will define:
* the dynamic variables that will be used in the session
* The requests that will be made

A typical session file might look like this:

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

See below for an explanation of the dynvars file.

The snippets section simply lists the snippet files which are to be executed one after another, in this case:

* config/snippets/hit_landing_page.yml
* config/snippets/hit_register_page.yml




### The snippets Folder

This folder contains the snippets.  Each snippet is one request, either GET or POST, that can be included in a session.

And example is hit_register_page.yml, inluded as the second snippet in the session file described above.

	request:
	  name: Select which type of LPA to create
	  thinktime: 5
	  url: '/create/lpa-type'
	  http_method: POST
	  params:
	    username: %%_username%%
	    lpa_type: Property and financial affairs
	    save: Save and continue
	 extract_dynvars:
    	activationurl: "id='activation_link' href='(.*)'"
	    
	    
Explanation of the entries in the above folder:

* __name__: The name of the request which will be included as a comment in the xml file
* __thinktime__: the value here specifies the average number of seconds that will be used as the thinktime between the last response and submitting this request (see http://tsung.erlang-projects.org/user_manual/conf-sessions.html#thinktimes for details). This is an optional entry, and if present, will override any default_thinktime value specified the environment file.
* __url__: the url to be GETted or POSTed.  This will be appended to the base_url specified int he environment file.
* __http_method__: self explanatory
* __params__: This element is optional and specifies any arameters to be submitted as key-value pairs. Either the key or the value part of the parameter (or indeed the url) can include a dynamic parameter, signified as such by being wrapped in "%%_  %%" as is username above.  The value for dynamic variables are set either by being defined at the top of the sessions file, or by a previous request extracting the value with an extract_dynvars section.  
* __extract_dynvars__: This element specifies that a dynamic variable is to be extracted from the response and used in a subsequent request.  In the example above, a dynamic variable entitled activationurl is extracted using the specified Regex and capture group (i.e. in the response:

	``<a id='activation_link' href='/activate?abd7337fec3'>Click Here</a>``

the string "/activate?abd7337fec3"	will be assigned to the variable activationurl, which can be referred to in a subsequent request as %%_actvationurl%%.


### The dynvars Folder

Files in this folder specify dynamic variables which can be automatically generated during the session.  There are three types of dynamic variables that can be specified:

* __random string__: A typical dynvar configuration file to define a random string might look like:

	<pre>
	dynvar:
	  type: random_string
	  length: 12
	</pre>	  

* __random number__:  A typical dynvar configuration file to define a random number  might look like:

	<pre>
	dynvar:
	  type: random_number
	  start: 500
	  end: 99000
	</pre>	  

	
* __erlang_funtion__: A typical dynvar configuration to define an erlang function that will be called to return the dynamic variable might look like: 

	<pre>
	dynvar:
	  code: |
	    fun({Pid,DynVars})->
	           {{Y, Mo, D},_}=calendar:now_to_datetime(erlang:now()),
	           DateAsString = io_lib:format('~2.10.0B%2F~2.10.0B%2F~4.10.0B', [D, Mo, Y]),
	           lists:flatten(DateAsString) end.
	  type: erlang
	</pre>
	
	
 

## Development Server Configuration and Tips for creating complex sessions

### Log File Format

It helps to have as much detail from the web server access logs as possible, so change the default format to include the request, and then you will see the parameters that are posted along with the request.

Edit 

<pre>/etc/nginx/nginx.conf</pre>

 and update the logstash-json entry to read as follows:

     log_format logstash_json '{ "@timestamp": "$time_iso8601", '
                             '"@fields": { '
                             '"remote_addr": "$remote_addr", '
                             '"remote_user": "$remote_user", '
                             '"body_bytes_sent": "$body_bytes_sent", '
                             '"request_time": "$request_time", '
                             '"status": "$status", '
                             '"request": "$request", '
                             '"request_method": "$request_method", '
                             '"http_referrer": "$http_referer", '
                             '"http_user_agent": "$http_user_agent" '
                             '}, "@request": "$request_body" }';

 and then restart the nginx server with the command:

 		sudo service nginx restart



### Clearing the access log before a run

The access log can be emptied before a test run by the following command:

    cat /dev/nul > /var/log/nginx/[logfile]



### Creating complex sessions

I have found the best way to know exactly what requests to send to replicate a complex user session is as follows:

1.	Ensure the nginx access logs include request information as detailed above
2.	Clear the access log as described above
3.	Manually go through the session on the browser, as if you were a user
4.	copy the access log to the tsung-wrapper folder on your dev machine as ``tmp/nginx.log``
5.	run ``ruby lib/nginx_analyser.rb`` - this will produce a CSV file which can be viewed in Excel or similar and show the url, http verb and any prameters posted
6.	use this to make up the snippet files and session file.






