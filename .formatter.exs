[
  import_deps: [:ecto, :ecto_sql, :phoenix],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}", "priv/*/seeds.exs"],
  locals_without_parens: [
    import_types: 1,
    import_fields: 1,
    add: 2,
    add: 3,
    add: 4,
    field: 2,
    field: 3,
    field: 4,
    arg: 2,
    arg: 3,
    resolve: 1,
    middleware: 1,
    belongs_to: 1,
    belongs_to: 2,
    belongs_to: 3,
    has_one: 1,
    has_one: 2,
    has_one: 3
  ]
]
