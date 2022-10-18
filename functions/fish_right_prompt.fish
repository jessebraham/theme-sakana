function fish_right_prompt
  set -l date (date "+%Y-%m-%d")
  set -l time (date "+%H:%M:%S")

  echo "$date $dkgrey@$normal $time "
end
