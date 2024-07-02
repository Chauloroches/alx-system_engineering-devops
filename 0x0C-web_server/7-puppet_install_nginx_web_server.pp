!/usr/bin/env bash

# Ensure the package is installed
package { 'nginx':
  ensure => installed,
}

# Ensure the Nginx service is running and enabled
service { 'nginx':
  ensure     => running,
  enable     => true,
  hasrestart => true,
  require    => Package['nginx'],
}

# Create the custom index.html file
file { '/var/www/html/index.html':
  ensure  => file,
  content => 'Hello World!',
  require => Package['nginx'],
}

# Configure the Nginx server block
file { '/etc/nginx/sites-available/default':
  ensure  => file,
  content => template('nginx/default.erb'),
  require => Package['nginx'],
  notify  => Service['nginx'],
}

# Create the Nginx configuration template
file { '/etc/puppetlabs/code/environments/production/modules/nginx/templates/default.erb':
  ensure  => file,
  content => @(END),
server {
    listen 80 default_server;
    listen [::]:80 default_server;

    root /var/www/html;
    index index.html;

    server_name _;

    location / {
        try_files $uri $uri/ =404;
    }

    location /redirect_me {
        return 301 https://www.youtube.com/watch?v=QH2-TGUlwu4;
    }
}
| END
}

# Ensure the directory for the template exists
file { '/etc/puppetlabs/code/environments/production/modules/nginx/templates/':
  ensure => directory,
  owner  => 'root',
  group  => 'root',
  mode   => '0755',
}
