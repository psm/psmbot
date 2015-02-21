# encoding: utf-8

namespace '/slack' do

  before do
    halt(400, 'Invalid token') unless ENV['SLACK_ISSUES_TOKEN'] && params['token'] == ENV['SLACK_ISSUES_TOKEN']
  end

  get '/issues/?:repo?' do |repo|
    opts = {filter: 'all', state: 'open'}

    if !(%w{directmessage general random}.include?(params['channel_name']))
      repo = params['channel_name']
      repo = 'recursoshumanos' if repo == 'rhtv'
    elsif params['text'] != ''
      repo = params['text']
    end

    repo = nil if repo == 'all'

    if repo && repo != ''
      issues = Octokit.issues "psm/#{repo}", opts
    else
      issues = Octokit.org_issues 'psm', opts
    end

    str = "Estos son todos los issues"
    str += " del repo '#{repo}'" if repo && repo != ''
    str += "\n\n"

    issues.each do |i|
      unless repo != ''
        str += i.repository.full_name
      end
      str += "\##{i.number}: <#{i.html_url}|#{i.title}>\n"
    end

    return str
  end


  get '/deploy/:channel/:status' do |repo,status|
    endpoint = ENV['SLACK_INCOMING']

    if status == 'deploy'
      color = 'good'
      title = 'Deployment listo!'
      items = [
        {title: 'sha', value: params[:sha], short: true},
        {title: 'restarted', value: params[:apps], short: true}
      ]
      items.push({title: 'compiled', value: 'yup', short: true}) if params[:compiled] == true

      plain_text = "#{title} **#{params[:sha]}**"
    else
      title = 'Error en deployment'
      color = 'danger'
      text = params[:error]
      plain_text = "#{title}: #{text}"
    end

    data = {
      fallback: plain_text,
      color: color,
      title: title
    }
    data[:items] = items if items
    data[:text] = text if text

    msg = {
      channel: "##{repo}",
      attachments: [data]
    }

    uri = URI::parse('https://hooks.slack.com')
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new endpoint, {'Content-type' => 'application/json'}
    req.body = msg.to_json
    res = http.request(req)
    return res.body
  end

end # namepsace