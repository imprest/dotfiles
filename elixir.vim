syn match elixirCustomOperators " def "  conceal cchar= " Space
syn match elixirCustomOperators " defp " conceal cchar=_

highlight link elixirCustomOperators Define

set concealcursor=nc
set conceallevel=1
