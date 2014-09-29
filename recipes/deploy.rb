#
# Cookbook Name:: optsicom
# Recipe:: deploy
#
# Copyright 2014, Optsicom
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'apt'

package 'gnupg'

# Inject settings.xml with credentials for deploying

deploy_secret = Chef::EncryptedDataBagItem.load_secret(node[:optsicom][:deploy][:secret_path])
maven = Chef::EncryptedDataBagItem.load("deploy", "maven", deploy_secret)

directory "#{node['optsicom']['deploy']['home']}/.m2" do
	owner node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['group']
	mode '0775'
end	

template "#{node['optsicom']['deploy']['home']}/.m2/settings.xml" do
	source 'settings.erb'
    variables( {
    	:password => maven["password"], 
    	:username => maven["username"] } )
end

# Inject gpg credentials for signing artifacts

gpg = Chef::EncryptedDataBagItem.load("deploy", "gpg", deploy_secret)

directory "#{node['optsicom']['deploy']['home']}/.gnupg" do
	owner node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['group']
	mode '0700'
end	

file "#{node['optsicom']['deploy']['home']}/.gnupg/optsicom-private.key" do
	owner node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['group']
	mode '0600'
	content gpg["private_key"]
	action	:create_if_missing
end

file "#{node['optsicom']['deploy']['home']}/.gnupg/optsicom-public.key" do
	owner node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['group']
	mode '0600'
	content gpg["public_key"]
	action	:create_if_missing
end

# Import gpg keys
execute "gpg --import #{node['optsicom']['deploy']['home']}/.gnupg/optsicom-public.key" do
	cwd node['optsicom']['deploy']['home']
	user node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['user']
	not_if "gpg --list-public-keys | grep '#{node['optsicom']['deploy']['key_name']}'",
		:user => node['optsicom']['deploy']['user'],
		:group => node['optsicom']['deploy']['user']
end

execute "gpg --import #{node['optsicom']['deploy']['home']}/.gnupg/optsicom-private.key" do
	cwd node['optsicom']['deploy']['home']
	user node['optsicom']['deploy']['user']
	group node['optsicom']['deploy']['user']
	not_if "gpg --list-secret-keys | grep '#{node['optsicom']['deploy']['key_name']}'", 
		:user => node['optsicom']['deploy']['user'],
		:group => node['optsicom']['deploy']['user']
end
