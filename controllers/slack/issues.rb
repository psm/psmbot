# encoding: utf-8

namespace '/slack' do

  before do
    halt(401, 'Invalid token') unless params['token'] = ENV['SLACK_TOKEN']
  end

  get '/issues/?:repo?' do |repo|
    opts = {filter: 'all', state: 'open'}

    if repo
      issues = Octokit.issues "psm/#{repo}", opts
    else
      issues = Octokit.org_issues 'psm', opts
    end

    str = ''

    issues.each do |i|
      unless repo
        str += i.repository.full_name
      end
      str += "\##{i.number}: [#{i.title}](#{i.html_url})\n\n"
    end

    return str

  end

end # namepsace