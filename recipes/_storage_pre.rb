include_recipe 'bacula-ng::_common'

solo_require_attributes 'bacula.storage.password' do
  node.set_unless['bacula']['storage']['password'] = secure_password
  node.save
end

tag 'bacula_storage'
