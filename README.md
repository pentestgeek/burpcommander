# burpcommander
Ruby command-line interface to Burp Suite's REST API

# Usage
	burpcommander VERSION: 1.0.1  -  UPDATED: 08/29/2018

    	-t, --target [IP Address]           Defaults to 127.0.0.1
    	-p, --port  [Port Number]           Defaults to 1337
    	-k, --key [API Key]                 If you require an API key specify it here
    	-i, --issue-type-id [String]        String to search for.  Example: "1048832"
    	-n, --issue-name [String]           String to search for.  Example: "Command Injection"
    	-D, --DESCRIPTION                   Returns the description of a requested issue
    	-M, --METRICS                       Returns the scan_metrics for a given task_id
    	-I, --ISSUES [Optional Number]      Returns the issue_events of a given task_id
    	-s, --scan [Complete URL]           Example: https://scantarget.com
    	-S, --scan-id [Number]              Returns ScanProgress for a given task_id
    	-U, --username [String]             Username to supply for an authenticated scan
    	-P, --password [String]             Password to supply for an authenticated scan
    	-v, --verbose                       Enables verbose output


# Generic Example
	./burpcommander.rb -k [API Key] -n "command injection" -D

## Command Output
<p>Operating system command injection vulnerabilities arise when an application incorporates user-controllable data into a command that is processed by a shell command interpreter. If the user data is not strictly validated, an attacker can use shell metacharacters to modify the command that is executed, and inject arbitrary further commands that will be executed by the server.</p> 
<p>OS command injection vulnerabilities are usually very serious and may lead to compromise of the server hosting the application, or of the application's own data and functionality. It may also be possible to use the server as a platform for attacks against other systems. The exact potential for exploitation depends upon the security context in which the command is executed, and the privileges that this context has regarding sensitive resources on the server.</p>                                

# Launch a Scan
	./burpcommander.rb -s www.youcanattackme.com -U admin -P password

	I, [2018-08-29T15:27:09.310594 #18919]  INFO -- : Successfuly initiated task_id: 4 against www.youcanattackme.com

# Query Scan Information
Get the scan_metrics of a given scan.

	./burpcommander.rb -S 4 -M

	{"crawl_requests_made"=>2264,
 	"crawl_requests_queued"=>0,
 	"audit_queue_items_completed"=>0,
 	"audit_queue_items_waiting"=>51,
 	"audit_requests_made"=>247,
 	"audit_network_errors"=>10,
 	"issue_events"=>21}

Get issue number 1 from a given scan.

	./burpcommander.rb -S 4 -I 1

	{"name"=>"File upload functionality",
 	"type_index"=>5245312,
 	"serial_number"=>"6437447914508597248",
 	"origin"=>"http://www.youcanattackme.com",
 	"path"=>"/vulnerabilities/upload/",
 	"severity"=>"info",
 	"confidence"=>"certain",
 	"description"=>
	"The page contains a form which is used to submit a user-supplied...
