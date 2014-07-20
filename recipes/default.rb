#
# Cookbook Name:: rails-setup
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# railsのデプロイディレクトリの作成
%w{
/var/www/
}.each do |path|
  directory path do
    owner node['rails-setup']['user']
    group node['rails-setup']['user']
    mode 00744
    action :create
    recursive true
  end
end

# nginx ログフォーマット指定
template "#{node['nginx']['dir']}/conf.d/log_format.conf" do
  source 'log_format.conf.erb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

# nginxをrails仕様に
%w{
/etc/nginx/conf.d/default.conf
}.each do |path|
  file path do
    action :delete
  end
end

template "#{node['nginx']['dir']}/sites-available/#{node['rails-setup']['application']}" do
  source 'rails_nginx.erb'
  owner  'root'
  group  node['root_group']
  mode   '0644'
  notifies :reload, 'service[nginx]'
end

nginx_site node['rails-setup']['application'] do
  enable true
end

# octopressで作成等したhtmlファイル郡のアプリケーションを相乗りさせる
if node['rails-setup']['html']
  template "#{node['nginx']['dir']}/sites-available/#{node['rails-setup']['html']}" do
    source 'html_nginx.erb'
    owner  'root'
    group  node['root_group']
    mode   '0644'
    notifies :reload, 'service[nginx]'
  end

  nginx_site node['rails-setup']['html'] do
    enable true
  end
end

node['rails-setup']['packages'].each do |name|
  package name do
    action :install
  end
end
