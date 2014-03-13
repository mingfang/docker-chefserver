nginx['enable_non_ssl'] = true

server_name = ENV['HOST']
api_fqdn server_name

nginx['url'] = "http://#{server_name}:9000"
nginx['server_name'] = server_name
lb['fqdn'] = server_name
bookshelf['vip'] = server_name
