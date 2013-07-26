bacula-ng cookbook
==================

This cookbook configures [Bacula](http://www.bacula.org/) backup system.

This cookbook's home is at https://github.com/3ofcoins/bacula-ng/

Requirements
------------

The cookbook has been developed and tested on Ubuntu 12.04 LTS. Backup
clients should work on any reasonably recent Linux distribution; no
guarantees about the director or storage daemon.

Required cookbooks:

- `postgresql` or `mysql` (for the director)
- `database` (for the director)
- `iptables`
- `openssl`

Usage
-----

Configure the backup server to add `recipe[bacula-ng::server]` to the
run list. It will configure the machine to run both director and
storage daemon. If you want to configure them separately, use
`bacula-ng::director` and `bacula-ng::storage` recipes.

On the director node, set `node['bacula']['director']['database']` to
`"mysql"` if you want to use MySQL rather than PostgreSQL as the
database backend.

On the nodes to be backed up, add `recipe[bacula-ng]` or
`recipe[bacula-ng::client]` to the run list. After configuring a new
client node, re-run Chef client on the director node to update its
configuration.

### Chicken and Egg

Bacula Director needs to know a storage node; storage node needs to
know its director. If both live on one machine, `bacula-ng::server`
recipe takes care of that. To run these on separate machines, until we
can think of anything better, the procedure is:

 - Set up storage node with `bacula-ng::storage` recipe. It will
   include a stub director entry in its config to be able to proceed.
 - Then, set up director node with `bacula-ng::director` recipe. It
   will find the storage and insert it into the configuration.
 - Run `chef-client` on storage node again. It will be able to find
   the director now, and update the storage daemon's configuration.

If you run chef-solo, chef-solo-search will help you configure it all
in a single pass.

### Jobs

Default configuration only includes two jobs: `BackupCatalog` to
backup the Bacula's catalog data, and `RestoreFiles` to restore backed
up files to the directory. It's up to user to add more specific jobs,
tailored for their environment. The jobs are defined in `bacula_jobs`
data bag. The data bag should contain following fields:

 - `id` -- obligatory data bag item ID
 - `name` -- if present, passed to the director config template as
   a pretty job name
 - `director_config` -- cookbook-qualified name of template with director's
   config snippet; defaults to `bacula-ng::bacula-dir-job.conf.erb`
 - `director_scripts` -- array of cookbook-qualified names of cookbook
   files with scripts to upload to director's
   `/etc/bacula/scripts/_id_/`; defaults to `[]`
 - `director_recipes` -- recipes to add to director's run list
 - `backup_scripts` -- array of cookbook-qualified names of cookbook
   files with scripts to upload to backup client's
   `/etc/bacula/scripts/_id_/`; defaults to `[]`
 - `backup_recipes` -- recipes to add to backup client's run list
 - `restore_scripts` -- array of cookbook-qualified names of cookbook
    files with scripts to upload to restore client's
    `/etc/bacula/scripts/_id_/`; defaults to `[]`
 - `restore_recipes` -- recipes to add to restore client's run list

The default `director_config` template will understand these
additional fields:

 - `files` -- array of files to add to fileset
 - `backup_settings` -- dictionary of settings pasted into backup
   job's `JobDefs` entry
 - `restore_settings` -- dictionary of settings pasted into restore
   job's entry

The director will include `director_config`, `director_scripts`, and
`director_recipes` for all defined jobs. Clients need to have the job
defined in `bacula.client.backup` or `bacula.client.restore`
attributes.

The `director_config` template will receive following variables:

 - `@job` -- the data bag itself
 - `@clients` -- array of nodes that have the job listed in their
   `bacula.client.backup` attribute

Please see the [templates/default/bacula-dir-job.conf.erb](default
bacula-dir-job.conf.erb) template for inspiration.

### Unmanaged Hosts

If you need to back up clients not managed by Chef, create a
`bacula_unmanagedhosts` data bag:

```json
{
  "id": "a-legacy-host",
  "bacula": {
    "fd": {
      "password": "WHATEVER"
    }
  },
  "ipaddress": "1.2.3.4"
}
```

Attributes
----------

 - `bacula.database` -- `"postgresql"` (default) or `"mysql"`
 - `bacula.use_iptables` -- if true (default), set up iptables rules
   to limit access to Bacula's ports
 - `bacula.storage.directory` -- directory to store backup tapes
 - `bacula.client.backup` -- array of backup jobs this client will
   need to run
 - `bacula.client.restore` -- array of restore jobs this client will
   run.

Recipes
-------

 - `default` - includes `client` recipe
 - `client` - includes `file` recipe
 - `server` - includes `director` and `storage` recipes
 - `file` - configures Bacula file daemon (client)
 - `director` - configures Bacula director daemon and console
 - `storage` - configures Bacula storage daemon

Author
------

Author:: Maciej Pasternacki <maciej@3ofcoins.net>
