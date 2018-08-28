#!/usr/bin/env ruby
require 'net/https'
require 'optparse'
require 'crack'


options = {}
args = OptionParser.new do |opts|
	opts.banner = "burpcommander VERSION: 1.0.0  -  UPDATED: 08/28/2018\r\n\r\n"
	opts.on("-t", "--target [IP Address]", "\tDefaults to 127.0.0.1") { |target| options[:target] = target }
	opts.on("-p", "--port  [Port Number]", "\tDefaults to 1337") { |port| options[:port] = port }	
	opts.on("-k", "--key [API Key]", "\tIf you require an API key specify it here") { |key| options[:key] = key }
	opts.on("-i", "--issue-type-id [String]", "\tString to search for.  Example: \"1048832\"") { |id| options[:id] = id }
	opts.on("-n", "--issue-name [String]", "\tString to search for.  Example: \"Command Injection\"") { |name| options[:name] = name }
	opts.on("-D", "--DESCRIPTION", "\tReturns the description of a requested issue") { |desc| options[:desc] = desc }
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
		self.issues = get_issues
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
end


bc = Burpcommander.new(options)
puts "#{bc.uri}#{bc.path}"
puts bc.issue_by_name(options[:name]) if options[:name]
puts bc.issue_by_id(options[:id]) if options[:id]
