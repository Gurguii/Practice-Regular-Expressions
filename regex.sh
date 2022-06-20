#!/bin/bash
function randomRegex()
{
  randN=$(( $RANDOM % $len + 0))
  while [[ $(echo $used_re | grep $randN) || (($randN == $current_rule_n)) ]]; do
    randN=$(( $RANDOM % $len + 0 ))
  done
  current_rule=${rules[$randN]}
  current_rule_n=$randN
}
function saveFile()
{
  while true; do
    printf "Filename(q to return): "
    read -r file
    if [[ ${file,,} == "q" ]]; then
      return
    fi
    if [[ ! -e $file ]]; then
      for mistaken in $wrongRules; do
        echo "$mistaken" >> $file
      done
      printf "[!] Done, file saved at %s\n" "$file"
      exit 0
    fi
    printf "File %s already exists\nappend new mistaken rules? y/n: "
    read -r ans
    if [[ ${ans,,} == "y" || ${ans,,} == "yes" ]]; then
      for mistaken in $wrongRules; do
        echo "$mistaken" >> "$file"
      done
      sort "$file" | uniq >> ".temp"
      rm $file
      mv ".temp" "$file"
      printf "[!] Done, file saved at %s\n" "$file"
      exit 0
    fi
    continue
  done
}
[[ -z $1 ]] && printf "How to use: bash %s <regex-file>\n" "$0" && exit 0
[[ ! -e $1 ]] && printf "[!] File %s doesn't exist\n[!] Exiting...\n" "$1" && exit 0
len=`<$1 wc -l`
rules=(`<$1`)
used_re=""
rightAns=0
wrongAns=0
wrongRules=""
randomRegex
while true; do
  clear
  printf "Rule => %s\nright: %s   wrong: %s   change: 'n'    save: 's'    exit: 'q'\n" "$current_rule" "$rightAns" "$wrongAns"
  printf "Check: "
  read -r check
  if [[ ${check,,} == "n" ]]; then
    randomRegex
    continue
  fi
  if [[ ${check,,} == "s" ]]; then
    saveFile
    continue
  fi
  if [[ ${check,,} == "q" ]]; then
    exit 0
  fi
  if [[ $check =~ $current_rule ]]; then
    read -p "Well done¡"
    let rightAns+=1
    used_re+="$randN "
    if (( $rightAns == $len && ${#wrongRules} > 0)); then
      printf "[!] All rules correctly answered\nsave mistakes? y/n: "
      read -r ans
      if [[ ${ans,,} == "y" || ${ans,,} == "yes" ]]; then
        saveFile
        exit 0
      fi
    fi
    if (( $rightAns == $len )); then
      printf "[!] All rules correctly answered without any mistake, you rock¡\n"
      exit 0
    fi
    randomRegex
    continue
  fi
  read -p "[!] Nope"
  if [[ ! $(echo $wrongRules | grep $current_rule) ]]; then
    wrongRules+="$current_rule "
  fi
  let wrongAns+=1
done
