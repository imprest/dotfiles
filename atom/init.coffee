atom.commands.add 'atom-workspace',
  'editor:focus-main': (e) ->
    atom.workspace.getActivePane().activate()

