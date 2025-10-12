oh-my-posh init pwsh --config 'C:\Users\Admin\scoop\apps\oh-my-posh\current\themes\amro.omp.json' | Invoke-Expression

Import-Module Terminal-Icons

Set-Alias -Name vim -Value nvim
Set-Alias -Name ls -Value Get-ChildItem

function make-link ($link, $target) {
  New-Item -ItemType SymbolicLink -Path $link -Target $target
}