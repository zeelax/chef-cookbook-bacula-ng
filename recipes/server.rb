# -*- coding: utf-8 -*-

include_recipe 'bacula-ng::client'
include_recipe 'bacula-ng::_storage_pre'
include_recipe 'bacula-ng::director'
include_recipe 'bacula-ng::storage'
