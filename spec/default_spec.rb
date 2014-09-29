require 'spec_helper'
require 'chefspec'

describe 'optsicom-chef::jenkins' do
  let(:chef_run) do 
    ChefSpec::Runner.new do |node|
      node.set['optsicom']['jenkins']['user'] = 'jenkins'
      node.set['optsicom']['jenkins']['group'] = 'jenkins'
      node.set['optsicom']['jenkins']['home'] = '/var/lib/jenkins'
      node.set['optsicom']['deploy']['secret_path'] = "secret_key"
    end.converge(described_recipe)
  end

  before do
    allow(Chef::EncryptedDataBagItem).to receive(:load_secret).with('secret_key').and_return("a secret")
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('username', 'maven', 'a secret').and_return('deployit')
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('password', 'maven', 'a secret').and_return('deployit')
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('private_key', 'gpg', 'a secret').and_return('private key')
    allow(Chef::EncryptedDataBagItem).to receive(:load).with('public_key', 'gpg', 'a secret').and_return('public key')
    stub_data_bag(:deploy).and_return(['maven'])
    stub_data_bag_item(:maven, 'maven').and_return({ id: 'maven', username: "deployit", password: "deployit" })
    stub_data_bag_item(:gpg, 'gpg').and_return({ id: 'gpg', private_key: "private key", public_key: "public key" })
    Fauxhai.mock(platform: "ubuntu", version: "14.04")
  end
  
  it 'creates settings.xml in .m2 folder' do
    expect(chef_run).to render_file('/var/lib/jenkins/.m2/settings.xml').with_content(/deployit/)
  end

  it 'creates public key' do
    expect(chef_run).to render_file('/var/lib/jenkins/.gnupg/optsicom-public.key').with_content("public key")
  end

  it 'creates private key' do
    expect(chef_run).to render_file('/var/lib/jenkins/.gnupg/optsicom-private.key').with_content("private key")
  end

end