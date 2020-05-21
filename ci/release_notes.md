# Improvements

* Added `postgres-addon` feature

  Use this feature to add postgres libraries to your shield core so that it
  can backup postgres databases that are provided by external sources that
  cannot support shield agents.

  Requires `params.postgres-addon-version` to be set to the version you are
  using.  Valid values are 9.0, 9.1, 9.2, 9.3, 9.4, 9.5, 9.6, 10 or 11
