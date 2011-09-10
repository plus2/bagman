# 0.0.5

- Fixed long standing bug where the bag would become something like `'{"serialised":"bag"}': null` [lachie]

# 0.0.4

- Was never pushed for some reason!
- `uncast` field type uses `:defaults`. [whalec]

# 0.0.3

- Added `bag_field` class method to `Bagman::Document`s. This allows for adding adhoc accessors for conveniently accessing verbatim bag values. [lachie]
- Added naive bag copying from superclasses. [lachie]

# 0.0.2

- Added `uncast` field type. This field type adds accessors for the field, and that's it! No ActiveRecord value casting is done, its all left up to the JSON serialiser.
  Useful for setting `Arrays` and `Hashes`. [lachie]


# 0.0.1

- Initial release [lachie]
