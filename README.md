# bitbucket_snagger
Snag public git repos from the internet and upload them to your private bitbucket server

# Credentials
* username, password and base_url are stored in a file at `~/.bitbucket_snagger.ini` and cannot be passed on the command line
* For an example file, see https://github.com/GeoffWilliams/bitbucket_snagger/tree/master/doc/.bitbucket_snagger.ini
* The permissions on `~/.bitbucket_snagger.ini` must be `0600`
* You can remove credentials with the logout command when you are finished

# Logging out
```shell
bundle exec bitbucket_snagger logout
```

# Creating and uploading a single git repo to bitbucket

* `--projectKey` is the 3 letter `projectKey`, eg `pup`
* `--repositorySlug` is the repository to upload to within the project, eg `apache`
* `--upstream` is the upstream repository to merge changes from
* `--verbosity` sets debug mode (optional)
* `snag` is the command to run (always `snag` to update)


```shell
bundle exec bitbucket_snagger \
  --projectKey pup \
  --repositorySlug apache \
  --upstream https://github.com/puppetlabs/puppetlabs-apache \
  --verbosity debug \
  snag
```

# Creating and updating lots of repos in bitbucket
Just make yourself a handy bash script, like this:

```script
#!/bin/bash
cmd="bitbucket_snagger --projectKey pup"
$cmd --repositorySlug accounts --upstream https://github.com/puppetlabs/puppetlabs-accounts snag
$cmd --repositorySlug apache --upstream https://github.com/puppetlabs/puppetlabs-apache snag
$cmd --repositorySlug concat --upstream https://github.com/puppetlabs/puppetlabs-concat snag
$cmd --repositorySlug firewall --upstream https://github.com/puppetlabs/puppetlabs-firewall snag
$cmd --repositorySlug git --upstream https://github.com/puppetlabs/puppetlabs-git snag
$cmd --repositorySlug haproxy --upstream https://github.com/puppetlabs/puppetlabs-haproxy snag
$cmd --repositorySlug inifile --upstream https://github.com/puppetlabs/puppetlabs-inifile snag
$cmd --repositorySlug java --upstream https://github.com/puppetlabs/puppetlabs-java snag
$cmd --repositorySlug java_ks --upstream https://github.com/puppetlabs/puppetlabs-java_ks snag
$cmd --repositorySlug motd --upstream https://github.com/puppetlabs/puppetlabs-motd snag
$cmd --repositorySlug mysql --upstream https://github.com/puppetlabs/puppetlabs-mysql snag
$cmd --repositorySlug noop --upstream https://github.com/trlinkin/trlinkin-noop snag
$cmd --repositorySlug nsswitch --upstream https://github.com/trlinkin/puppet-nsswitch snag
$cmd --repositorySlug ntp --upstream https://github.com/puppetlabs/puppetlabs-ntp snag
$cmd --repositorySlug postgresql --upstream https://github.com/puppetlabs/puppetlabs-postgresql snag
$cmd --repositorySlug puppet_agent --upstream https://github.com/puppetlabs/puppetlabs-puppet_agent snag
$cmd --repositorySlug ssh --upstream https://github.com/saz/puppet-ssh snag
$cmd --repositorySlug staging --upstream https://github.com/voxpupuli/puppet-staging snag
$cmd --repositorySlug stdlib --upstream https://github.com/puppetlabs/puppetlabs-stdlib snag
$cmd --repositorySlug sudo --upstream https://github.com/saz/puppet-sudo snag
$cmd --repositorySlug tagmail --upstream https://github.com/puppetlabs/puppetlabs-tagmail snag
$cmd --repositorySlug tomcat --upstream https://github.com/puppetlabs/puppetlabs-tomcat snag
$cmd --repositorySlug vcsrepo --upstream https://github.com/puppetlabs/puppetlabs-vcsrepo snag
```
Making this prettier is left as an exercise for the reader

## Notes
* Attempting to access insecure `http` repositories will work but will output a warning message
