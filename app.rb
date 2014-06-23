#!/usr/bin/env ruby
# encoding: utf-8

if File.exists? './env'

  File.read('./env').split("\n").each do |l|
    k,v = l.split(' ')
    ENV[k] = v
  end

end

Octokit.configure do |c|
  c.access_token = ENV['GITHUB_TOKEN']
end

error do
  status 500
  puts 'error'
end

Dir['controllers/**/*.rb'].each do |f|
  require "./#{f}"
end