#!/usr/bin/env ruby
# encoding: utf-8


error do
  status 500
  puts 'error'
end

require 'net/http'
require 'json'

Dir['config/**/*.yml'].each do |f|
  name = f.split('/').last.gsub('.yml', '')
  set name.to_sym, YAML::load_file("./#{f}")
end

Dir['lib/**/*.rb'].each do |f|
  require "./#{f}"
end

Dir['controllers/**/*.rb'].each do |f|
  require "./#{f}"
end

configure do
  if File.exists? './env'

    File.read('./env').split("\n").each do |l|
      k,v = l.split(' ')
      ENV[k] = v
    end

  end

  Octokit.configure do |c|
    c.access_token = ENV['GITHUB_TOKEN']
  end

  Slack.configure ENV['SLACK_INCOMING']
end