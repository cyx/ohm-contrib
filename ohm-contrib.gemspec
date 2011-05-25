
Gem::Specification.new do |s|
  s.name = 'ohm-contrib'
  s.version = "0.1.1"
  s.summary = %{A collection of decoupled drop-in modules for Ohm.}
  s.description = %{Includes a couple of core functions such as callbacks, timestamping, typecasting and lots of generic validation routines.}
  s.author = "Cyril David"
  s.email = "cyx.ucron@gmail.com"
  s.homepage = "http://github.com/cyx/ohm-contrib"

  s.specification_version = 2 if s.respond_to? :specification_version=

  s.files = ["lib/ohm/contrib.rb", "lib/ohm/contrib/locking.rb", "lib/ohm/contrib/prefetch_attributes.rb", "lib/ohm/contrib/struct.rb", "lib/ohm/contrib/number_validations.rb", "lib/ohm/contrib/typecast.rb", "lib/ohm/contrib/soft_delete.rb", "lib/ohm/contrib/date_validations.rb", "lib/ohm/contrib/slug.rb", "lib/ohm/contrib/web_validations.rb", "lib/ohm/contrib/callbacks.rb", "lib/ohm/contrib/timestamping.rb", "lib/ohm/contrib/fulltext_searching.rb", "lib/ohm/contrib/boundaries.rb", "lib/ohm/contrib/looseref.rb", "lib/ohm/contrib/extra_validations.rb", "lib/ohm/contrib/length_validations.rb", "lib/ohm/contrib/scope.rb", "lib/ohm/contrib/active_model_extension.rb", "README.markdown", "LICENSE", "Rakefile", "test/looseref_test.rb", "test/typecast_decimal_test.rb", "test/instance_callbacks_test.rb", "test/typecast_boolean_test.rb", "test/typecast_integer_test.rb", "test/macro_callbacks_test.rb", "test/activemodel_test.rb", "test/typecast_existing_attribute_test.rb", "test/soft_delete_test.rb", "test/typecast_array_test.rb", "test/boundaries_test.rb", "test/typecast_time_test.rb", "test/helper.rb", "test/typecast_timezone_test.rb", "test/membership_validation_test.rb", "test/scope_test.rb", "test/web_validations_test.rb", "test/date_validations_test.rb", "test/typecast_float_test.rb", "test/callbacks_lint.rb", "test/autoload_test.rb", "test/typecast_string_test.rb", "test/fulltext_searching_test.rb", "test/timestamping_test.rb", "test/number_validations_test.rb", "test/fixtures/ascii8bit.txt", "test/typecast_date_test.rb", "test/typecast_hash_test.rb", "test/length_validations_test.rb", "test/slug_test.rb", "test/struct_test.rb"]

  s.require_paths = ['lib']

  s.rubyforge_project = "ohm-contrib"

  s.has_rdoc = false
  s.add_dependency "ohm"

  s.add_development_dependency "cutest"
  s.add_development_dependency "redis"
  s.add_development_dependency "lunar"
  s.add_development_dependency "override"
end

