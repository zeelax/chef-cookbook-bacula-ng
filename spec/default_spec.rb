# -*- coding: utf-8 -*-

require 'chefspec'

describe 'bacula-ng::default' do
  let(:chef_run) { ChefSpec::ChefRunner.new.converge 'bacula-ng::default' }
  it 'should do something' do
    pending 'Your recipe examples go here.'
  end
end
