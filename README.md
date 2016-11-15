# bitbucket_snagger
Snag public git repos from the internet and upload them to your private bitbucket server

# Testing
```shell
bundle exec bitbucket_snagger --project puppet --repo apache --upstream https://github.com/puppetlabs/puppetlabs-apache  --verbosity debug --base-url http://10.20.1.3:7990 --username admin --password admin snag
```
