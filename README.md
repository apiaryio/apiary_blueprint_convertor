![logo](https://raw.github.com/apiaryio/api-blueprint/master/assets/logo_apiblueprint.png)

# Apiary Blueprint AST Convertor [![Build Status](https://travis-ci.org/apiaryio/apiary_blueprint_convertor.png?branch=master)](https://travis-ci.org/apiaryio/apiary_blueprint_convertor)
A migration tool for legacy [Apiary Blueprint](https://github.com/apiaryio/blueprint-parser) AST into [API Blueprint](http://apiblueprint.org) AST. Converts Apiary Blueprint AST serialized into a JSON file to [API Blueprint AST](https://github.com/apiaryio/api-blueprint-ast) JSON representation (`vnd.apiblueprint.ast.raw+json; version=2.0`).

**NOTE**: *This library is deprecated in favour of
[fury](https://github.com/apiaryio/fury) and the [Fury API Blueprint
Serializer](https://github.com/apiaryio/fury-adapter-apib-serializer).*

## Installation
Add this line to your application's Gemfile:

    gem 'apiary_blueprint_convertor'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install apiary_blueprint_convertor

## Usage

```sh
$ apiary_blueprint_convertor path/to/legacy/ast.json
```

See the [convert feature](features/convert.feature) for details or run `apiary_blueprint_convertor --help`.

### Convert Legacy Apiary Blueprint to API Blueprint
Use this convertor together with the legacy [Apiary Blueprint Parser](https://github.com/apiaryio/blueprint-parser) and API Blueprint Composer – [Matter Compiler](https://github.com/apiaryio/matter_compiler). 

1. Parse Legacy Apiary Blueprint into its JSON AST using `Apiary Blueprint Parser`
2. Convert legacy JSON AST into API Blueprint JSON AST using `apiary_blueprint_convertor`
3. Compose API Blueprint from API Blueprint JSON AST using `matter_compiler`

For example: 

```sh
$ blueprint-parser legacy_blueprint.apib | apiary_blueprint_convertor | matter_compiler --format json > new_blueprint.md
```

## Contributing
1. Fork this repository (http://github.com/apiaryio/apiary_blueprint_convertor/fork)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License
MIT License. See the [LICENSE](LICENSE) file.
