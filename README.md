# bitbucket_snagger
Snag public git repos from the internet and upload them to your private bitbucket server

# Testing

## http
```shell
bundle exec bitbucket_snagger --project pup --repo apache --upstream https://github.com/puppetlabs/puppetlabs-apache  --verbosity debug --base-url 10.20.1.3:7990 --username admin --password admin --insecure snag
```

## https
```shell
bundle exec bitbucket_snagger --project pup --repo apache --upstream https://github.com/puppetlabs/puppetlabs-apache  --verbosity debug --base-url 10.20.1.3:7990 --username admin --password admin --insecure snag
```
