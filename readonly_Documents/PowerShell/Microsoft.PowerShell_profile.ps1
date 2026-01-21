# Profile


function rmrf ($path) { remove-item -force -recurse $path }


# starship prompt
Invoke-Expression (&starship init powershell)

