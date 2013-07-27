module BaculaNG
  module Helpers
    def pg_has_table?(dbname, table)
      require 'pg'
      db = ::PGconn.new host: 'localhost',
                        port: node['postgresql']['config']['port'],
                        user: 'postgres',
                        password: node['postgresql']['password']['postgres'],
                        dbname: 'template1'
      return false if db.query("SELECT 1 FROM pg_database where datname = '#{dbname}'").num_tuples.zero?
      db.close

      db = ::PGconn.new host: 'localhost',
                        port: node['postgresql']['config']['port'],
                        user: 'postgres',
                        password: node['postgresql']['password']['postgres'],
                        dbname: dbname
      return !db.query("SELECT 1 FROM pg_tables WHERE schemaname='public' AND tablename='#{table}'").num_tuples.zero?
    ensure
      db.close rescue nil
    end

    def solo_require_attributes(*attributes)
      if Chef::Config[:solo]
        unless (missing = attributes.select { |attr|node["$.#{attr}"].empty? }).empty?
          Chef::Application.fatal! "You must set #{missing.join(', ')} in chef-solo mode."
        end
      else
        yield if block_given?
      end
    end
  end
end

class Chef::Recipe
  include BaculaNG::Helpers
end

class Chef::Resource
  include BaculaNG::Helpers
end
