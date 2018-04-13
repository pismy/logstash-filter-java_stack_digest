# Logstash Plugin

This is a filter plugin for [Logstash](https://github.com/elastic/logstash) that enables computing a *stable* digest 
(MD5) from a Java stack trace.

It is fully free and fully open source. The license is Apache 2.0, meaning you are pretty much free to use it however you want in whatever way.


## Documentation

Goal and principles are described in the project [GitHub pages](https://pismy.github.io/logstash-filter-java_stack_digest/).

You'll also find an [online debugger](https://pismy.github.io/logstash-filter-java_stack_digest/debugger.html) to help 
you configure and debug your plugin options.


## Install in Logstash

- Download the plugin from [RubyGems](https://rubygems.org/gems/logstash-filter-java_stack_digest).
```sh
gem install logstash-filter-java_stack_digest
```
- Install the plugin from the Logstash home
```sh
bin/logstash-plugin install logstash-filter-java_stack_digest.gem
```
- Configure the plugin in Logstash configuration
- Start Logstash and proceed to test the plugin

## Configuration

This plugin supports the following configuration options:
* `source` (type `string`): the name of the field containing the Java stack trace option (default value: `"stack_trace"`)
* `target` (type `string`): the name of the field to assign the computed stack trace digest (default value: `"stack_digest"`)
* `exclude_no_source` (type `boolean`): whether stack trace elements without source info (no filename or line number) should be excluded from the digest  (default value: `true`)
* `includes` (type `array` of `string`): RegExp patterns determining whether stack trace elements should be **included** from digest (defaults to none - _exclusion patterns only_)
* `excludes` (type `array` of `string`): RegExp patterns determining whether stack trace elements should be **excluded** from digest (defaults to standard dynamic Java reflection and generated classes patterns)

Filter configuration example:
```ruby
  filter {
    java_stack_digest {
      source => 'java_stack'
      target => 'error_digest'
      exclude_no_source => true
      includes => ['^com\\.xyz\\.', '^java\\.']
      excludes => ['\\$\\$FastClassByCGLIB\\$\\$', '\\$\\$EnhancerBySpringCGLIB\\$\\$']
    }
  }
```

## Contributing

All contributions are welcome: ideas, patches, documentation, bug reports, complaints, and even something you drew up on a napkin.

Programming is not a required skill. Whatever you've seen about open source and maintainers or community members  saying "send patches or die" - you will not see that here.

It is more important to the community that you are able to contribute.

For more information about contributing, see the [CONTRIBUTING](https://github.com/elastic/logstash/blob/master/CONTRIBUTING.md) file.
