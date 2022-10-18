set blue   (set_color 61AFEF)
set dkgrey (set_color 7F848E)
set gold   (set_color E5C07B)
set green  (set_color 98C379)
set ltgrey (set_color ABB2BF)
set normal (set_color normal)
set orange (set_color D19A66)
set purple (set_color C678DD)
set red    (set_color E06C75)


function __sakana_user
  echo "$purple$USER"
end

function __sakana_hostname
  set -l host (hostname -s | awk '{print tolower($0)}')
  echo "$gold$host"
end


function __sakana_git_branch_state
  # Create an empty array to store our icons
  set -l icons ()

  # Check for any untracked files
  set -l git_untracked (command git ls-files --others --exclude-standard 2> /dev/null)
  if [ -n "$git_untracked" ]
    set -a icons "$green+$normal"
  end

  # Check if there are any local changes to be commited
  if git_is_touched
    set -a icons "$gold!$normal"
  else
    set -a icons "$green✔$normal"
  end

  # Check for any stashed files
  if git_is_stashed
    set -a icons "$blue⚑$normal"
  end

  # Print each icon with appropriate padding
  echo -n "$ltgrey"
  echo -n "["

  for icon in $icons
    echo -n " $icon"
  end
  echo -n " "

  echo -n "$ltgrey]$dkgrey"

  # Check if the branch is ahead, behind, or diverged of remote
  set -l commits (command git rev-list --count --left-right "@{upstream}...HEAD" 2> /dev/null)
  switch "$commits"
  case ""
    # No upstream
  case "0"\t"0"
    # Even with upstream
  case "*"\t"0"
    set -l count (echo $commits | awk '{print $1}')
    echo -n " $count commits behind"
  case "0"\t"*"
    set -l count (echo $commits | awk '{print $2}')
    echo -n " $count commits ahead"
  case "*"
    set -l behind (echo $commits | awk '{print $1}')
    set -l ahead  (echo $commits | awk '{print $2}')
    echo -n " $behind commit behind, $ahead ahead"
  end

  echo
end

function __sakana_git_state
  set -l is_dot_git (string match '*/.git' $cwd)

  if git_is_repo; and test -z $is_dot_git
    #git update-index --really-refresh -q 1> /dev/null

    set -l git_branch (command git symbolic-ref --quiet --short HEAD 2> /dev/null; or git rev-parse --short=7 HEAD 2> /dev/null; or echo -n '(???)')
    echo -n "$red git$dkgrey:$blue$git_branch$normal "

    __sakana_git_branch_state
  else
    echo
  end
end


function fish_prompt
  set -l user (__sakana_user)
  set -l host (__sakana_hostname)
  set -l cwd  (prompt_pwd)

  echo
  echo -n "$user$dkgrey@$host $normal$cwd"

  __sakana_git_state

  # Rust integration
  if test -e "Cargo.toml"
    set -l rustc   (rustc --version | awk '{print $2}' | cut -d "-" -f1)
    set -l toolchain (rustup show | tail -n 3 | head -n 1 |  cut -d '-' -f 1 | cut -d ' ' -f 1)

    echo -n "🦀 $orange$toolchain$dkgrey@$ltgrey$rustc "
  end

  set -l lambda "λ"
  echo "$green$lambda$normal "
end
