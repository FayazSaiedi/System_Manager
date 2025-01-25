#!/bin/bash

modify_permissions ()
{
  options=$(dialog --title "Modify Directory" --stdout \
                   --checklist "Modifiy permissions for: $1\nCheck option with SPACE."  21 31 10 \
                   UR "User Read" off \
                   UW "User Write" off \
                   UE "User Execute" off \
                   GR "Group Read" off \
                   GW "Group Write" off \
                   GE "Group Execute" off \
                   OR "Other Read" off \
                   OW "Other Write" off \
                   OE "Other Execute" off \
                   SUON "Setuid ON" off \
                   SGON "Setgid ON" off \
                   YES "Stickybit ON" off \
                   )
  if [[ $? == 0 ]]; then
    userP=()
    groupP=()
    otherP=()
    stickybit=()
    for i in $options; do
      if [[ "$i" == "UR" ]]; then
        userP+="r"
      elif [[ "$i" == "UW" ]]; then
        userP+="w"
      elif [[ "$i" == "UE" ]]; then
        userP+="x"
      elif [[ "$i" == "GR" ]]; then
        groupP+="r"
      elif [[ "$i" == "GW" ]]; then
        groupP+="w"
      elif [[ "$i" == "GE" ]]; then
        groupP+="x"
      elif [[ "$i" == "OR" ]]; then
        otherP+="r"
      elif [[ "$i" == "OW" ]]; then
        otherP+="w"
      elif [[ "$i" == "OE" ]]; then
        otherP+="x"
      elif [[ "$i" == "SUON" ]]; then
        userP+="s"
      elif [[ "$i" == "SGON" ]]; then
        groupP+="s"
      elif [[ "$i" == "YES" ]]; then
        stickybit="t"
      fi
    done
    userP=$(echo $userP | sed 's/ //g')
    groupP=$(echo $groupP | sed 's/ //g')
    otherP=$(echo $otherP | sed 's/ //g')
    chmod u="$userP" "$1"
    chmod u="$groupP" "$1"
    chmod u="$otherP" "$1"
    if [[ "$stickybit" == "t" ]]; then
      chmod +t "$1"
    fi

  fi
}

modify_group ()
{
  groupowner=$(dialog --title "Modify Directory" --stdout --inputbox "\nNew group owner:" 10 25)
  if grep "^$groupowner:" /etc/group &> /dev/null; then
    dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
    if [[ $? == 0 ]]; then
      chgrp "$groupowner" "$1"
      if [[ $? == 0 ]]; then
        dialog --title "SUCCESS" --msgbox "\n\nGroup ownership changed." 10 30
      else
        dialog --title "ERROR" --msgbox "\n\nCould not change group ownership." 10 30
      fi
    else
      dialog --msgbox "\n\n  Modification cancelled." 10 30
    fi
  else
    dialog --title "ERROR" --msgbox "\n\n Group does not exist." 10 30
  fi
}

modify_owner ()
{
  owner=$(dialog --title "Modify Directory" --stdout --inputbox "\nNew owner:" 10 25)
  if [[ $? == 0 ]]; then
    if grep "^$owner:" /etc/passwd &> /dev/null; then
      chown "$owner" "$1"
      if [[ $? == 0 ]]; then
        dialog --title "SUCCESS" --msgbox "\n\nOwnership changed." 10 30
      else
        dialog --title "ERROR" --msgbox "\n\nCould not change ownership." 10 30
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
    fi
  fi
}

modify_directory_name ()
{
  name=$(dialog --title "Modify Directory" --stdout --inputbox "\nName to change to:" 10 25)
  if [[ $? == 0 ]]; then
    oldname=$(echo "$1" | rev | cut -d'/' -f2 | rev)
    newpath=$(echo "$1" | sed "s/\/$oldname\//\/$name/")
    mv "$1" "$newpath"
    if [[ $? == 0 ]]; then
      dialog --title "SUCCESS" --msgbox "\n\nDirectory name changed." 10 30
    else
      dialog --title "ERROR" --msgbox "\n\nCould not change\n directory name." 10 30
    fi
  fi
}

modify_directory ()
{
  folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select what you want to modify:" 11 63 4 \
  MN "Modify Name         (Change name of the directory)" \
  MO "Modify Owner        (Change owner of the directory)" \
  MG "Modify Group        (Change group ownership)" \
  MP "Modify Permissions  (Modify the directory permissions)" \
  )
  
  if [[ $? == 0 ]]; then
    if [[ $folderoption == MN ]]; then
      modify_directory_name "$1"
    elif [[ $folderoption == MO ]]; then
      modify_owner "$1"
    elif [[ $folderoption == MG ]]; then
      modify_group "$1"
    else
      modify_permissions "$1"
    fi
  fi
}

list_directory ()
{
  dialog --title "List file of directory" --no-ok --cancel-label "Back" --fselect /home/ 19 40
}

directory_information ()
{
  select=$(dialog --title "Choose Directory" --stdout --dselect /home/ 19 40)
  if [[ $? == 0 ]]; then
    #test if select is a directory before continuing
    if [[ -d $select ]]; then
      directory=$(ls -lah "$select" | grep " \.$")
      
      readU=$(echo "$directory" | cut -c2)
      writeU=$(echo "$directory" | cut -c3)
      execU=$(echo "$directory" | cut -c4)
      readG=$(echo "$directory" | cut -c5)
      writeG=$(echo "$directory" | cut -c6)
      execG=$(echo "$directory" | cut -c7)
      readO=$(echo "$directory" | cut -c8)
      writeO=$(echo "$directory" | cut -c9)
      execO=$(echo "$directory" | cut -c10)

      owner=$(echo "$directory" | awk '{print $3}')
      group=$(echo "$directory" | awk '{print $4}')
      modified=$(echo "$directory" | awk '{print $6, $7, $8}')

      userP=()
      groupP=()
      otherP=()
      setuid="OFF"
      setgid="OFF"
      stickybit="OFF"

      #User permissions
      if [[ $readU == "r" ]]; then
        userP+="Read "
      fi
      if [[ $writeU == "w" ]]; then
        userP+="Write "
      fi
      if [[ $execU == "x" ]] || [[ $execU == "s" ]]; then
        userP+="Execute"
      fi

      #Group permissions
      if [[ $readG == "r" ]]; then
        groupP+="Read "
      fi
      if [[ $writeG == "w" ]]; then
        groupP+="Write "
      fi
      if [[ $execG == "x" ]]  || [[ $execU == "s" ]]; then
        groupP+="Execute"
      fi

      #Other permissions
      if [[ $readO == "r" ]]; then
        otherP+="Read "
      fi
      if [[ $writeO == "w" ]]; then
        otherP+="Write "
      fi
      if [[ $execO == "x" ]] || [[ $execU == "t" ]]; then
        otherP+="Execute"
      fi

      #Empty string check
      if [[ $userP == "" ]]; then
        otherP="No permissions"
      fi
      if [[ $groupP == "" ]]; then
        otherP="No permissions"
      fi
      if [[ $otherP == "" ]]; then
        otherP="No permissions"
      fi

      #Setuid, setgid and stickybit
      if [[ $execU == "s" ]] || [[ $execU == "S" ]]; then
        setuid="ON"
      fi
      if [[ $execG == "s" ]] || [[ $execG == "S" ]]; then
        setgid="ON"
      fi
      if [[ $execO == "t" ]] || [[ $execO == "T" ]]; then
        stickybit="ON"
      fi
      information=$(
        echo "Owner:         $owner"
        echo "Group:         $group"
        echo "Last modified: $modified"
        echo "Setuid:        $setuid"
        echo "Setgid:        $setgid"
        echo "Stickybit:     $stickybit"
        echo -e "\nPermissions:"
        echo "User:          $userP"
        echo "Group:         $groupP"
        echo "Other:         $otherP"
      )

      dialog --title "Directory Information" \
            --no-collapse \
            --yes-label "Change" \
            --no-label "Back" \
            --yesno "Information on $select\n\
            \n${information//$'\n'/\\n}" 17 38
      if [[ $? == 0 ]]; then
        modify_directory "$select"
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n  Directory doesn't exist." 10 30
    fi
  fi
}

delete_directory ()
{
  directory=$(dialog --title "Choose directory to delete" --stdout --fselect /home/ 19 40)
  if [[ $? == 0 ]]; then
    dialog --title "Directory Manager" --yesno "You sure you want to delete directory $directory" 10 30
    if [[ $? == 0 ]]; then
      rmdir "$directory" &> /dev/null #Removes directory if empty.
      if [[ $? != 0 ]]; then
        rm -R "$directory" &> /dev/null #Removes directory and it's files recursively.
      else 
        dialog --title "SUCCESS" --msgbox "\n\n  Directory deleted." 10 30
      fi
    fi
  fi
}

add_directory ()
{
  path=$(dialog --title "Choose where to add directory" --stdout --dselect /home/ 19 40)
  if [[ $? == 0 ]]; then
    name=$(dialog --title "Add Directory" --stdout --inputbox "\nDirectory name:" 10 25)
    if [[ $? == 0 ]]; then
      mkdir "$path$name" &> /dev/null #Adds a directory with the name $name at path $path.
      if [[ $? == 0 ]]; then
        dialog --title "SUCCESS" --msgbox "\n\n  Directory created." 10 30
      else
        dialog --title "ERROR" --msgbox "\n\nCould not create directory." 10 30
      fi
    fi
  fi
}

directory_menu ()
{
  folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select one directory option" 11 63 4 \
  AD "Add directory          (Create a new directory)" \
  LD "List directory         (View content in a directory)" \
  VM "View/Modify Directory  (View directory properties)" \
  DD "Delete Directory       (Delete a directory)" \
  )

  if [[ $? == 0 ]]; then
    if [[ $folderoption == AD ]]; then
      add_directory
    elif [[ $folderoption == LD ]]; then
      list_directory
    elif [[ $folderoption == VM ]]; then
      directory_information
    else
      delete_directory
    fi
  fi
}

directory_menu