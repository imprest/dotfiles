; .config/nvim/after/queries/elixir
; extends

; Svelte
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#eq? @_sigil_name "V")
  (#set! injection.language "svelte"))

; SQL
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @injection.content
  (#eq? @_sigil_name "Q")
  (#set! injection.language "sql"))
