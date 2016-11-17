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

# Creating and uploading bitbucket

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

## Notes
* Attempting to access insecure `http` repositories will work but will output a warning message
