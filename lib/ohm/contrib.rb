module Ohm
  module Contrib
    VERSION = "0.1.1"
  end

  autoload :ActiveModelExtension, "ohm/contrib/active_model_extension"
  autoload :Boundaries,           "ohm/contrib/boundaries"
  autoload :Timestamping,         "ohm/contrib/timestamping"
  autoload :LengthValidations,    "ohm/contrib/length_validations"
  autoload :WebValidations,       "ohm/contrib/web_validations"
  autoload :NumberValidations,    "ohm/contrib/number_validations"
  autoload :DateValidations,      "ohm/contrib/date_validations"
  autoload :ExtraValidations,     "ohm/contrib/extra_validations"
  autoload :Typecast,             "ohm/contrib/typecast"
  autoload :Locking,              "ohm/contrib/locking"
  autoload :Callbacks,            "ohm/contrib/callbacks"
  autoload :Slug,                 "ohm/contrib/slug"
  autoload :Scope,                "ohm/contrib/scope"
  autoload :SoftDelete,           "ohm/contrib/soft_delete"
  autoload :FulltextSearching,    "ohm/contrib/fulltext_searching"
  autoload :Looseref,             "ohm/contrib/looseref"
  autoload :Struct,               "ohm/contrib/struct"
end
