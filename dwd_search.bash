#! /bin/bash

# normalize qnode input to uppercase
qnode=${1^^}

# check for missing argument
if [[ -z "$qnode" ]]
then
  echo "** no qnode provided **"

# validate qnode input
# -- 2 or more chars long
# -- first char Q or P
# -- followed by 1 or more digits
elif [[ ${#qnode} -le 1 || ! $qnode =~ ^[QP] || ! ${qnode:1} =~ [0-9]+ ]]  
then
  echo "** invalid input **"
  echo "** Qnodes begin with Q or P followed one or more digits (e.g. Q1, Q76) **"

# search for qnode in dwd api
else
  res=$(curl -s --location --request GET 'https://dwd.isi.edu/api?&q='"$qnode"'&type=exact_match&extra_info=true&language=en&item=qnode')

  # match dwd entry by qnode
  res_match=$(echo $res | jq ".[] | select(.qnode==\"$qnode\")")

  # check if no matching entry
  if [[ -z "$res_match" ]]
  then
    echo "$(tput setaf 1)$(tput bold)** not in DWD **$(tput sgr0)"

  # otherwise print results
  else
    res_label=$(echo $res_match | jq -r '.label[0]')
    res_qnode=$(echo $res_match | jq -r '.qnode')

    echo "$(tput setaf 2)$(tput bold)** DWD MATCH **$(tput sgr0)"
    echo "Qnode ID:" $res_qnode
    echo "Qnode Label:" $res_label

  fi
fi
