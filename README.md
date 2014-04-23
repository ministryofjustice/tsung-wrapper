# tsung-wrapper



This project enables the creation of complex XML files for load testing using Tsung, from a series of 
yaml configuration files.  The tool can be used to just produce the XML file, or actually run the tsung session.




## Configuration Files

Configuration files are located in the /config directory (for testing, they are located in /spec/config).
The config directory contains the dtd file to be used, plus three folders: 

*  dynvars
*  environments
*  load_profiles
*  matches
*  sessions
*  snippets


### The dynvars Folder

Files in this folder specify dynamic variables which can be automatically generated during the session - see Dynamic variable definition and substitution below.



 
### The environments Folder
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
		load_profile: average

		user_agents:
		  - name: Linux Firefox
		    user_agent_string: "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.7.8) Gecko/20050513 Galeon/1.3.21"
		    probability: 80
		  - name: Windows Firefox
		    user_agent_string: "Mozilla/5.0 (Windows; U; Windows NT 5.2; fr-FR; rv:1.7.8) Gecko/20050511 Firefox/1.0.4"
		    probability: 20

All of the above elements must be present.

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

### The sessions Folder

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



### The snippets Folder

This folder contains the snippets.  Each snippet is one request, either GET or POST, and can be included in a session.

And example is hit_register_page.yml, inluded as the second snippet in the session file described above.

	request:
	  name: Hit Register Page
	  url: 'user/register'
	  http_method: GET

The name of the snippet as defined in the file will be included into the XML file as a comment.

The url will be appended to the base_url defined in the environment configuration.


### Dynamic variable definition and substitution

A request can include paramters which use dynamically generated variables - 'dynvars' which can come from one of two places:

*  from a definition in the dynvars folder
*  extracted from a response earlier in the session


##### Defnining dynamic variables in the dynvars folder

Each type of dynvar is defined in its own file in the dynvars folder.  There are three types of dynvar:

* random string
* random number
* erlang

See examples in the spec/config/dynvars folder to see how they are defined.

When you want to use them in the session, you must include a dynvars section in your session file which details what definition to use, and what name you will assign to it, e.g. 

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


#### Extracting dynvars from responses.

If you need to extract some information from a response to a request, you 
specify this in the snippet that will generate the request in the extract_dynvars section.

This section is a list of key value pairs, where the key is the name that will be given to the variable, and the value is the regular expression that will extract the value.

For example:

	
	request:
	  thinktime: 2
	  name: Hit Register Page and store AuthURL from response
	  url: '/user/register'
	  http_method: POST
	  params:
	    email: "%%_username%%"
	    email_confirm: "%%_username%%"
	    password: Passw0rd
	    password_confirm: Passw0rd
	    confirmUnderstanding: 1
	    submit: I understand
	    setAutoKey: "I5iOAmnnQaq5JPI8JHYcdXQPlI09bQnHoeAxb7xYjTe+FLPTVHZho3zK0mu41ouPmxLXJlZYi"
	  extract_dynvars:
	    activationurl: "id='activation_link' href='(.*)'"
	    page_title: "&lt;title&gt;(.*)&lt;/title&gt;"

In the above example, given that the request contained:

	<a id="activation_link" href="http://test.com/activate/abc123">Activate</a>

Then a dynamic variable called activationurl will be created with the contents:
	
	http://test.com/activate/abc123

This can be used in subsequent requests using the normal substitution convention, i.e. 

	%%_activationurl%%



## Command line usage
The command line tool is run by executing ruby lib/wrap.rb from the root directory of the project.
It can be used to generate xml to stdout, or a temporary file which is then piped into tsung.



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
    


## Development Server Configuration

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


