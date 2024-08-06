set: if set._if or true then builtins.removeAttrs set [ "_if" ] else { }
