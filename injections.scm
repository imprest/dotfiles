; .config/nvim/after/queries/elixir
; extends

; Svelte
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @svelte
(#eq? @_sigil_name "V"))

; SQL
(sigil
  (sigil_name) @_sigil_name
  (quoted_content) @sql
(#eq? @_sigil_name "Q"))
