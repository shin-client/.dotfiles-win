function make-link ($link, $target) {
  New-Item -ItemType SymbolicLink -Path $link -Target $target
}

function notepad {
  Start-Process notepad++ $args
}

function scoopExport {
  scoop export > $env:USERPROFILE\.dotfiles-win\.config\scoop\scoop.json
}