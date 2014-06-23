# encoding: utf-8

namespace '/slack' do

  before do
    halt(400, 'Invalid token') unless ENV['SLACK_ISSUES_TOKEN'] && params['token'] == ENV['SLACK_ISSUES_TOKEN']
  end

  get '/issues/?:repo?' do |repo|
    opts = {filter: 'all', state: 'open'}

    repo = repo || params['text']
    if repo && repo != ''
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