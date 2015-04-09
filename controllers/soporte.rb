# encoding: utf-8
namespace '/soporte' do

  post '/alert/:cliente' do |cliente|
    token = headers['HTTP_AUTH']

    if settings.clientes[:cliente] != token
      halt(400, 'Token inválido')
    end

    request.body.rewind
    payload = JSON.parse(request.body.read, symbolize_names: true)

    fields = [{title: 'cliente', value: cliente, short: true}]
    fields << {title: 'app', value: payload[:app], short: true} if payload[:app]
    fields << {title: 'backtrace', value: payload[:backtrace].shift(10).join("\n"), short: false} if payload[:backtrace]
    fields += payload[:fields] if payload[:fields]

    emoji = 'information_source'
    color = '#CCCCCC'
    case payload[:level]
      when 'warning'
        color = 'warning'
        emoji = color
      when 'error'
        color = 'danger'
        emoji = 'sos'
    end

    attachment = {
      fallback: payload[:message],
      color: color,
      pretext: payload[:message],
      fields: fields
    }
    attachment[:text] = payload[:info] if payload[:info]


    notification = {
      channel: '#debug',
      username: 'debugger',
      icon_emoji: ":#{emoji}:",
      attachments: [attachment]
    }

    Slack.send(notification)
  end

end