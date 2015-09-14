require 'spec_helper'

describe 'account::user' do
  describe 'account with default values' do
    let( :title ) { 'user' }

    it do
      should contain_group( title ).with({
        'ensure' => 'present',
        'name'   => title,
        'system' => false,
        'gid'    => nil,
        'before' => ["User[#{title}]"],
      })
    end

    it do
      should contain_user( title ).with({
        'ensure'     => 'present',
        'name'       => title,
        'uid'        => nil,
        'shell'      => '/bin/bash',
        'gid'        => title,
        'groups'     => [],
        'home'       => "/home/#{title}",
        'managehome' => true,
        'system'     => false,
        'before'     => ["File[#{title}_home]"],
      })
    end

    it do
      should contain_exec( "#{title}_set_initial_password" )
    end

    it do
      should contain_file( "#{title}_home" ).with({
        'ensure'  => 'directory',
        'path'    => "/home/#{title}",
        'owner'   => title,
        'group'   => title,
        'mode'    => '750',
        'before'  => ["File[#{title}_sshdir]"],
      })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({
        'ensure'  => 'directory',
        'path'    => "/home/#{title}/.ssh",
        'owner'   => title,
        'group'   => title,
        'mode'    => '700',
      })
    end

    it do
      should contain_file( "#{title}_sshdir_authorized_keys" ).with({
        'ensure'  => 'absent',
        'path'    => "/home/#{title}/.ssh/authorized_keys",
      })
    end
  end

  describe 'account with custom values' do
    let( :title ) { 'admin' }
    let( :params ) {{
      :username    => 'sysadmin',
      :shell       => '/bin/zsh',
      :manage_home => false,
      :home_dir    => '/opt/admin',
      :system      => true,
      :uid         => 777,
      :groups      => [ 'sudo', 'users' ],
    }}

    it do
      should contain_group( title ).with({
        'name'   => params[:username],
        'system' => true,
        'gid'    => params[:uid],
      })
    end

    it do
      should contain_user( title ).with({
        'name'        => params[:username],
        'uid'         => params[:uid],
        'shell'       => params[:shell],
        'gid'         => params[:username],
        'groups'      => params[:groups],
        'home'        => params[:home_dir],
        'manage_home' => params[:manage_home] == false ? nil : true,
        'system'      => params[:system],
      })
    end

    it do
      should contain_file( "#{title}_home" ).with({
        'path'  => params[:home_dir],
        'owner' => params[:username],
        'group' => params[:username],
      })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({
        'path' => "#{params[:home_dir]}/.ssh",
        'owner' => params[:username],
        'group' => params[:username],
      })
    end
  end

  describe 'account with no dedicated group' do
    let( :title ) { 'user' }
    let( :params ) {{ :create_group => false }}

    it do
      should_not contain_group( title )
    end

    it do
      should contain_user( title ).with({ 'gid' => 'users' })
    end

    it do
      should contain_file( "#{title}_home" ).with({ 'group' => 'users' })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({ 'group' => 'users' })
    end
  end

  describe 'account with no dedicated group' do
    let( :title ) { 'user' }
    let( :params ) {{ :create_group => false, :gid => 'staff' }}

    it do
      should_not contain_group( title )
    end

    it do
      should contain_user( title ).with({ 'gid' => params[:gid] })
    end

    it do
      should contain_file( "#{title}_home" ).with({ 'group' => params[:gid] })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({ 'group' => params[:gid] })
    end
  end

  describe 'account with authorized_keys' do
    let( :title ) { 'user' }
    let( :params ) {{
      :ssh_keys => [
          'ssh-rsa AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVV== test1@test',
          'ssh-rsa 12345678910123456789012345678901234567890123== test2@test',
      ]
    }}

    it do
      should contain_file( "#{title}_sshdir" ).with({
        'ensure'  => 'directory',
        'path'    => "/home/#{title}/.ssh",
        'owner'   => title,
        'group'   => title,
        'mode'    => '700',
      })
    end

    it do
      should contain_file( "#{title}_sshdir_authorized_keys" ).with({
        'ensure'  => 'present',
        'path'    => "/home/#{title}/.ssh/authorized_keys",
        'owner'   => title,
        'group'   => title,
        'mode'    => '600',
        'require' => "File[#{title}_sshdir]",
      })
    end
  end

  describe 'removed account' do
    let( :title ) { 'user' }
    let( :params ) {{
      :ensure => 'absent',
      :ssh_keys => [
          'ssh-rsa AABBCCDDEEFFGGHHIIJJKKLLMMNNOOPPQQRRSSTTUUVV== test1@test',
          'ssh-rsa 12345678910123456789012345678901234567890123== test2@test',
      ]
    }}

    it do
      should contain_group( title ).with({
        'ensure' => 'absent',
        'name'   => title,
        'gid'    => nil,
      })
    end

    it do
      should contain_user( title ).with({
        'ensure'     => 'absent',
        'name'       => title,
        'uid'        => nil,
        'shell'      => '/bin/bash',
        'gid'        => title,
        'groups'     => [],
        'home'       => "/home/#{title}",
        'managehome' => true,
        'system'     => false,
      })
    end

    it do
      should contain_exec( "#{title}_set_initial_password" )
    end

    it do
      should contain_file( "#{title}_home" ).with({
        'ensure'  => 'absent',
        'path'    => "/home/#{title}",
      })
    end

    it do
      should contain_file( "#{title}_sshdir" ).with({
        'ensure'  => 'absent',
        'path'    => "/home/#{title}/.ssh",
      })
    end

    it do
      should contain_file( "#{title}_sshdir_authorized_keys" ).with({
        'ensure'  => 'absent',
        'path'    => "/home/#{title}/.ssh/authorized_keys",
      })
    end
  end
end

