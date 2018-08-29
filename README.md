# burpcommander
Ruby command-line interface to Burp Suite's REST API

# Usage
	$ ./burpcommander.rb -h               
		burpcommander VERSION: 1.0.0  -  UPDATED: 08/28/2018                            

    	-t, --target [IP Address]           Defaults to 127.0.0.1                   
   	-p, --port  [Port Number]           Defaults to 1337                        
   	-k, --key [API Key]                 If you require an API key specify it here
    	-i, --issue-type-id [String]        String to search for.  Example: "1048832"
    	-n, --issue-name [String]           String to search for.  Example: "Command Injection"
    	-D, --DESCRIPTION                   Returns the description of a requested issue
    	-v, --verbose                       Enables verbose output                  


# Example
	./burpcommander.rb -k [API Key] -n "command injection" -D

## Command Output
<p>Operating system command injection vulnerabilities arise when an application incorporates user-controllable data into a command that is processed by a shell command interpreter. If the user data is not strictly validated, an attacker can use shell metacharacters to modify the command that is executed, and inject arbitrary further commands that will be executed by the server.</p> 
<p>OS command injection vulnerabilities are usually very serious and may lead to compromise of the server hosting the application, or of the application's own data and functionality. It may also be possible to use the server as a platform for attacks against other systems. The exact potential for exploitation depends upon the security context in which the command is executed, and the privileges that this context has regarding sensitive resources on the server.</p>                                

