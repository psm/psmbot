#!/usr/bin/env ruby
# encoding: utf-8

Octokit.configure do |c|
  c.access_token = env['GITHUB_TOKEN']
end

Dir['controllers/**/*.rb'].each do |f|
  require "./#{f}"
end