This release modernizes the SHIELD kit to work well with
Genesis 2.6 features and functionalities.  Primarily, this
involves a heavier emphasis on kit-provided hooks to do heavy
lifting.

- Genesis 2.6.0 is the minimum version supported by this kit now.

- The `info` hook provides information about accessing the SHIELD
  core via CLI or WEB UI,

- Exodus data is now provided, for integration with other deployments.

- The `new` and `blueprint` hooks replace a lot of stuff that was
  in kit.yml (params and friends), while removing the complexity
  of the subkit decomposition.

- The `addon` hook provides for kit-specific functionality like
  visiting the SHIELD web UI in the browser, and generating BOSH
  runtime configs for colocating the SHIELD agent on other
  deployments.

- The `post-deploy` hook gives the operator a gentle nudge in the
  direction of _next steps_.
