set blue   (set_color 61AFEF)
set dkgrey (set_color 7F848E)
set gold   (set_color E5C07B)
set green  (set_color 98C379)
set ltgrey (set_color ABB2BF)
set normal (set_color normal)
set orange (set_color D19A66)
set purple (set_color C678DD)
set red    (set_color E06C75)


function __sakana_git_branch_name
  set -l branch (command git symbolic-ref --quiet --short HEAD 2>/dev/null; or command git show-ref --head -s --abbrev | head -n1 2>/dev/null)
  echo -n "$red git$dkgrey:$blue$branch$normal "
end

function __sakana_git_branch_state
  # Create an empty array to store our icons
  set -l icons ()

  # Check for any untracked files
  set -l git_untracked (command git ls-files --others --exclude-standard 2>/dev/null)
  if [ -n "$git_untracked" ]
    set -a icons "$green✚$normal"
  end

  # Check if there are any local changes to be commited
  if git_is_touched
    set -a icons "$gold✎$normal"
  else
    set -a icons "$green✔$normal"
  end

  # Check for any stashed files
  if git_is_stashed
    set -a icons "$blue⚑$normal"
  end

  # Print each icon with appropriate padding
  # There should always be at least one icon
  echo -n "$ltgrey"
  echo -n "["

  for icon in $icons
    echo -n " $icon"
  end

  echo -n " $ltgrey]"
end


function fish_prompt
  set -l host (hostname -s)
  set -l cwd  (prompt_pwd)

  echo
  echo -n "$purple$USER$dkgrey@$gold$host $normal$cwd"

  # Git integration
  if git_is_repo
    git update-index --really-refresh -q 1>/dev/null

    __sakana_git_branch_name
    __sakana_git_branch_state

    echo -n "$dkgrey "
    git_ahead
  end

  echo

  # Python integration
  if test $VIRTUAL_ENV
    set -l venv   (basename $VIRTUAL_ENV)
    set -l python (python -V | cut -d " " -f 2)

    echo -n "🐍 $blue$venv$normal@$python "
  end

  # Rust integration
  if test -e "Cargo.toml"
    set -l _version  (rustc --version | cut -d " " -f 2)
    set -l rustc     (echo $_version  | cut -d "-" -f 1)
    set -l toolchain (echo $_version  | cut -d "-" -f 2)

    echo -n "🦀 $orange$toolchain$dkgrey@$ltgrey$rustc "
  end

  set -l lambda "λ"
  echo "$green$lambda$normal "
end
