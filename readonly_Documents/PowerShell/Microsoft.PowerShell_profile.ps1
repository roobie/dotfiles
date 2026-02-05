function Get-GitBranch {
	try {
		$branch = git rev-parse --abbrev-ref HEAD 2>$null
		if ($branch -and $branch -ne 'HEAD') { return " [$branch]" }
	}
	catch {}
	return ""
}

function Is-Elevated {
	$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
	$principal = New-Object Security.Principal.WindowsPrincipal($identity)
	return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function hitta ($name) {
	get-command $name | select source
}
function rmrf ($what) {
	remove-item -force -recurse $what
}

function prompt {
	$path = $(Get-Location)
	$datetime = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
	$gitBranch = Get-GitBranch
	$elevated = Is-Elevated
	$elevatedMark = if ($elevated) { "🛑 " } else { "" }
	$promptText = "$datetime | $elevatedMark$path$gitBranch`n> "

	# Set window title
	$repo = ""
	try {
		$repo = git rev-parse --show-toplevel 2>$null
		if ($repo) {
			$repoName = Split-Path $repo -Leaf
			$branch = git rev-parse --abbrev-ref HEAD 2>$null
			$host.UI.RawUI.WindowTitle = "$repoName ($branch) - $path$elevatedMark"
		}
		else {
			$host.UI.RawUI.WindowTitle = "$elevatedMark$path"
		}
	}
	catch {
		$host.UI.RawUI.WindowTitle = "$elevatedMark$path"
	}
	return $promptText
}

if (get-command scoop-search -ErrorAction SilentlyContinue) {
	Invoke-Expression (&scoop-search --hook)
}
Invoke-Expression (&starship init powershell)
Invoke-Expression (& { (zoxide init powershell | Out-String) })
set-alias -Name ls -Value eza
