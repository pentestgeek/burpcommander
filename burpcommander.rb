#!/usr/bin/env ruby
require 'net/https'
require 'optparse'
require 'crack'
require 'celluloid/current'
require 'pry'
require 'pp'
include Celluloid::Internals::Logger


options = {}
args = OptionParser.new do |opts|
	opts.banner = "burpcommander VERSION: 1.0.1  -  UPDATED: 08/29/2018\r\n\r\n"
	opts.on("-t", "--target [IP Address]", "\tDefaults to 127.0.0.1") { |target| options[:target] = target }
	opts.on("-p", "--port  [Port Number]", "\tDefaults to 1337") { |port| options[:port] = port }	
	opts.on("-k", "--key [API Key]", "\tIf you require an API key specify it here") { |key| options[:key] = key }
	opts.on("-i", "--issue-type-id [String]", "\tString to search for.  Example: \"1048832\"") { |id| options[:id] = id }
	opts.on("-n", "--issue-name [String]", "\tString to search for.  Example: \"Command Injection\"") { |name| options[:name] = name }
	opts.on("-D", "--DESCRIPTION", "\tReturns the description of a requested issue") { |desc| options[:desc] = true }
	opts.on("-M", "--METRICS", "\tReturns the scan_metrics for a given task_id") { |metrics| options[:metrics] = metrics }
	opts.on("-I", "--ISSUES [Optional Number]", "\tReturns the issue_events of a given task_id") { |issues| options[:issues] = issues }
	opts.on("-s", "--scan [Complete URL]", "\tExample: https://scantarget.com") { |scanurl| options[:scanurl] = scanurl }
	opts.on("-S", "--scan-id [Number]", "\tReturns ScanProgress for a given task_id") { |taskid| options[:taskid] = taskid }
	opts.on("-U", "--username [String]", "\tUsername to supply for an authenticated scan") { |username| options[:username] = username }
	opts.on("-P", "--password [String]", "\tPassword to supply for an authenticated scan") { |password| options[:password] = password }
	opts.on("-v", "--verbose", "\tEnables verbose output\r\n\r\n") { |v| options[:verbose] = true }
end
args.parse!(ARGV)


class Burpcommander
	attr_accessor :apikey, :http, :target, :headers, :verbose, 
		:port, :uri, :path, :issues, :options

	def initialize(options)
		self.options = options
		self.target = options[:target] ? options[:target] : "127.0.0.1"
		self.port = options[:port] ? options[:port] : "1337"
		self.uri = URI.parse("http://#{target}:#{port}")
		self.path = options[:key] ? "/#{options[:key]}/v0.1/" : "/v0.1/"
		self.http = setup_http
		verify_api_key if options[:key]
		self.issues = get_issues
	end

	def launch_scan
		path = self.path + "scan"
		username = options[:username] ? options[:username] : ""
		password = options[:password] ? options[:password] : ""
		post = "{\"application_logins\":[{\"password\":\"" +
			"#{password}\",\"username\":\"#{username}\"" +
			"}],\"urls\":[\"#{options[:scanurl]}\"]}"
		response = http.post(path, post, {})
		if response.code == "201"
			info "Successfuly initiated task_id: #{response.header["location"]} against #{options[:scanurl]}"
		else
			warn "Error launching scan against #{options[:scanurl]}"
		end
	end

	def scan_progress
		path = self.path + "scan/" + options[:taskid]
		response = http.get(path, {})
		progress = Crack::JSON.parse(response.body)
		return progress["scan_metrics"] if options[:metrics]
		if options.has_key? :issues
			return progress["issue_events"][options[:issues].to_i-1]["issue"] if options[:issues]
			return progress["issue_events"]
		end
		return progress
	end

	def issue_by_name(name)
		results = Array.new
		self.issues.each do |issue|
			result = options[:desc] ? issue["description"] : issue
			results << result if issue["name"].downcase.include? name.downcase
		end
		return results
	end
	
	def issue_by_id(id)
		results = Array.new
		self.issues.each do |issue|
			result = options[:desc] ? issue["description"] : issue
			results << result if issue["issue_type_id"].to_s.include? id
		end
		return results
	end

	private

		def get_issues
			path = self.path + "/knowledge_base/issue_definitions"
			response = http.get(path, {})
			return Crack::JSON.parse(response.body)
		end

		def setup_http
			http = Net::HTTP.new(uri.host, uri.port)
			http.use_ssl = false
			return http
		end

		def verify_api_key
			response = http.get(self.path {})
			if response.code == "200"
				info "Validated API Key" if options[:verbose]
			elsif response.code == "401"
				warn "Invalid API Key specified"
				exit
			else
				warn "Something bad happened :("
				exit
			end
		end
end

bc = Burpcommander.new(options)
puts bc.issue_by_name(options[:name]) if options[:name]
puts bc.issue_by_id(options[:id]) if options[:id]
bc.launch_scan if options[:scanurl]
pp bc.scan_progress if options[:taskid]
