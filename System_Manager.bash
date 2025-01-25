#!/bin/bash

#Application made by Marcus Hammarström and Fayaz Saiedi. DVA249_Case_C 15.

modify_permissions ()
{
  flag=0 #Flag for checking if permission changes were successful or not.
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
    setuid=()
    setgid=()
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
        setuid="s"
      elif [[ "$i" == "SGON" ]]; then
        setgid="s"
      elif [[ "$i" == "YES" ]]; then
        stickybit="t"
      fi
    done
    userP=$(echo $userP | sed 's/ //g')
    groupP=$(echo $groupP | sed 's/ //g')
    otherP=$(echo $otherP | sed 's/ //g')
    chmod u="$userP" "$1"
    chmod g="$groupP" "$1"
    chmod o="$otherP" "$1"
    if [[ "$setuid" == "s" ]]; then
      chmod u+s "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    else
      chmod u-s "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    fi

    if [[ "$setgid" == "s" ]]; then
      chmod g+s "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    else
      chmod g-s "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    fi

    if [[ "$stickybit" == "t" ]]; then
      chmod +t "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    else
      chmod -t "$1"
      if [[ $? != 0 ]]; then
        flag=1
      fi
    fi
    if [[ $flag == 0 ]]; then
      dialog --title "SUCCESS" --msgbox "\n\n Permissions modified." 10 30
    else
      dialog --title "ERROR" --msgbox "\n\nDid not manage to change all permissions." 10 30
    fi
  fi
}

modify_group ()
{
  groupowner=$(dialog --title "Modify Directory" --stdout --inputbox "\nNew group owner:" 10 25)
  if [[ $? == 0 ]]; then
    if grep "^$groupowner:" /etc/group &> /dev/null; then #Check if group exists.
      dialog --title "Modify Directory" --yesno "\n\n    Are you sure?" 10 30
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
  fi
}

modify_owner ()
{
  owner=$(dialog --title "Modify Directory" --stdout --inputbox "\nNew owner:" 10 25)
  if [[ $? == 0 ]]; then
    if grep "^$owner:" /etc/passwd &> /dev/null; then
      dialog --title "Modify Directory" --yesno "\n\n    Are you sure?" 10 30
      if [[ $? == 0 ]]; then
        chown "$owner" "$1"
        if [[ $? == 0 ]]; then
          dialog --title "SUCCESS" --msgbox "\n\n   Ownership changed." 10 30
        else
          dialog --title "ERROR" --msgbox "\n\nCould not change ownership." 10 30
        fi
      else
        dialog --msgbox "\n\n  Modification cancelled." 10 30
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
    dialog --title "Modify Directory" --yesno "\n\n    Are you sure?" 10 30
    if [[ $? == 0 ]]; then
      oldname=$(echo "$1" | rev | cut -d'/' -f2 | rev)
      newpath=$(echo "$1" | sed "s/\/$oldname\//\/$name/")
      mv "$1" "$newpath"
      if [[ $? == 0 ]]; then
        dialog --title "SUCCESS" --msgbox "\n\nDirectory name changed." 10 30
      else
        dialog --title "ERROR" --msgbox "\n\nCould not change\n directory name." 10 30
      fi
    else
      dialog --msgbox "\n\n  Modification cancelled." 10 30
    fi
  fi
}

modify_directory ()
{
  modifydirectoryflag=0
  while [[ $modifydirectoryflag != 1 ]]; do
    folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select what you want to modify:" 11 63 4 \
                  MN "Modify Name         (Change name of the directory)" \
                  MO "Modify Owner        (Change owner of the directory)" \
                  MG "Modify Group        (Change group ownership)" \
                  MP "Modify Permissions  (Modify the directory permissions)" \
                  )
    
    if [[ $? == 0 ]]; then
      if [[ $folderoption == MN ]]; then
        clear
        modify_directory_name "$1"
      elif [[ $folderoption == MO ]]; then
        clear
        modify_owner "$1"
      elif [[ $folderoption == MG ]]; then
        clear
        modify_group "$1"
      else
        clear
        modify_permissions "$1"
      fi
    else
      clear
      modifydirectoryflag=1
    fi
  done
}

list_directory ()
{
  dialog --title "List file of directory" --no-ok --cancel-label "Back" --fselect /home/ 19 40
}

directory_information ()
{
  select=$(dialog --title "Choose Directory" --stdout --dselect /home/ 19 40)
  if [[ $? == 0 ]]; then
    #Test if select is a directory before continuing
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
      if [[ $execO == "x" ]] || [[ $execO == "t" ]]; then
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
    else
      dialog --msgbox "\n\n  Deletion cancelled." 10 30
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
  directoryflag=0

  while [[ $directoryflag != 1 ]]; do
    folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select one directory option" 11 63 4 \
    AD "Add directory          (Create a new directory)" \
    LD "List directory         (View content in a directory)" \
    VM "View/Modify Directory  (View directory properties)" \
    DD "Delete Directory       (Delete a directory)" \
    )

    if [[ $? == 0 ]]; then
      if [[ $folderoption == AD ]]; then
        clear
        add_directory
      elif [[ $folderoption == LD ]]; then
        clear
        list_directory
      elif [[ $folderoption == VM ]]; then
        clear
        directory_information
      else
        clear
        delete_directory
      fi
    else
      directoryflag=1
    fi
    clear
  done
}

change_gid ()
{
  group=$(dialog --title "Change GID" --stdout --inputbox "\nGroup to change GID:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$group:" /etc/group &> /dev/null
      if [[ $? == 0 ]]; then
        gid=$(grep "^$group:" /etc/group | cut -d: -f3)
        newgid=$(dialog --title "Change GID" --stdout --inputbox "\nEnter new GID:" 10 25)
        if [[ $? == 0 ]]; then
          if [[ "$newgid" -ge "1000" ]] && [[ "$newgid" -le "60000" ]]; then
            cat "/etc/group" | cut -d: -f3 | grep "$newgid"
            if [[ $? == 0 ]]; then
              dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
              if [[ $? == 0 ]]; then
                members=($(grep "^$group:" /etc/group | cut -d':' -f4 | sed 's/,/ /g'))
                members+=($(grep ":$gid:" /etc/passwd | cut -d':' -f1))
                groupmod -g "$gid" "$group"
                if [[ $? == 0 ]]; then
                  for member in $members; do
                    usermod -aG "$group" "$member"
                  done
                  dialog --title "SUCCESS" --msgbox "\n\n  Group ID changed." 10 30
                else
                  dialog --title "ERROR" --msgbox "\n\nCould not change group ID." 10 30
                fi
              else
                dialog --msgbox "\n\n  Modification cancelled." 10 30
              fi
            else
              dialog --title "ERROR" --msgbox "\n\n  Group ID is taken." 10 30
            fi
          else
            dialog --title "ERROR" --msgbox "\n  Incorrect group ID.\n\n  Range is 1000-60000." 10 30
          fi
        fi
      else
        dialog --title "ERROR" --msgbox "\n\n  Group doesn't exist." 10 30
      fi
  fi
}

remove_from_group ()
{
  user=$(dialog --title "Remove From Group" --stdout --inputbox "\nUser to remove:" 10 25)
  if [[ $? == 0 ]]; then
		grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      group=$(dialog --title "Remove From Group" --stdout --inputbox "\nGroup to remove from:" 10 25)
      if [[ $? == 0 ]]; then
        grep "^$group:" /etc/group &> /dev/null
        if [[ $? == 0 ]]; then
          dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
          if [[ $? == 0 ]]; then
            deluser "$user" "$group"
            exitstatus=$?
            if [[ "$exitstatus" == "0" ]]; then
              dialog --title "SUCCESS" --msgbox "\n\n User removed from group." 10 30
            else
              dialog --title "ERROR" --msgbox "\n\nCouldn't remove user from group." 10 30
            fi
          else
            dialog --msgbox "\n\n  Modification cancelled." 10 30
          fi
        else
          dialog --title "ERROR" --msgbox "\n\n  Group doesn't exist." 10 30
        fi
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n  User doesn't exist." 10 30
    fi
  fi
}

add_to_group ()
{
	user=$(dialog --title "Add To Group" --stdout --inputbox "\nUser to add:" 10 25)
	if [[ $? == 0 ]]; then
		grep "^$user:" /etc/passwd &> /dev/null
		if [[ $? == 0 ]]; then
			group=$(dialog --title "Add To Group" --stdout --inputbox "\nGroup to add to:" 10 25)
			if [[ $? == 0 ]]; then
				grep "^$group:" /etc/group &> /dev/null
				if [[ $? == 0 ]]; then
          id -nG "$user" | grep "$group"
          if [[ $? == 1 ]]; then
            usermod -aG "$group" "$user"
            if [[ $? == 0 ]]; then
              dialog --title "SUCCESS" --msgbox "\n\n  User added to group." 10 30
            else
              dialog --title "ERROR" --msgbox "\n\n  Error adding user." 10 30
            fi
          else
            dialog --title "ERROR" --msgbox "\n\n User already in group." 10 30
          fi
				else
					dialog --title "ERROR" --msgbox "\n\n  Group doesn't exist." 10 30
				fi
			fi
		else
		dialog --title "ERROR" --msgbox "\n\n  User doesn't exist." 10 30
		fi
	fi
}

view_group ()
{
  group=$(dialog --title "View Group" --stdout --inputbox "\nGroup to view:" 10 25)
    if [[ $? == 0 ]]; then
      if grep "^$group:" /etc/group &> /dev/null; then
        members=($(grep "^$group:" /etc/group | cut -d: -f4 | sed 's/,/ /g'))        
        memberlist=()
        gid=$(grep "^$group:" /etc/group | cut -d: -f3)
        members+=($(grep ":$gid:" /etc/passwd | cut -d':' -f1))
        count=${#members[@]}

        for (( i = 0 ; i < $count ; i++ )); do
        memberlist+=$(
            echo "$((i+1)): ${members[$i]}\n"
            )
        done

        dialog --title "View Group" --msgbox "\nMembers in group\n$group - $gid:\n\n${memberlist//$'\n'/\\n}" 18 25

      else
        dialog --title "ERROR" --msgbox "\n\n  Group doesn't exist." 10 30
      fi
    fi
}

delete_group ()
{
	group=$(dialog --title "Delete Group" --stdout --inputbox "\nGroup to delete:" 10 25)
	if [[ $? == 0 ]]; then
		grep "^$group:" /etc/group &> /dev/null
		if [[ $? == 0 ]]; then
      gid=$(grep "^$group:" /etc/group | cut -d: -f3)
      if [[ "$gid" -ge "1000" ]] && [[ "$gid" -le "60000" ]]; then
        dialog --title "Group Manager" --yesno "\n\n    Are you sure?" 10 30
        if [[ $? == 0 ]]; then
          groupdel "$group" &> /dev/null
          exitstatus="$?"
          if [[ "$exitstatus" == "0" ]]; then
            dialog --title "SUCCESS" --msgbox "\n\n    Group deleted." 10 30
          elif [[ "$exitstatus" == "8" ]]; then
            dialog --title "ERROR" --msgbox "\n\nCan't remove user's primary group." 10 30
          else
            dialog --title "ERROR" --msgbox "\n\n  Error deleting group." 10 30
          fi
        else
          dialog --msgbox "\n\n  Modification cancelled." 10 30
        fi
      else
        dialog --title "ERROR" --msgbox "\n\nCan't delete system group." 10 30
      fi
		else
		  dialog --title "ERROR" --msgbox "\n\n  Group doesn't exist." 10 30
		fi
	fi
}

list_group ()
{
  declare -a groupnames
  readarray -t groupnames < <(awk -F: '$3 >= 1000 && $3 <= 60000 {print $1}' /etc/group)
	groups=${#groupnames[@]}
  grouplist=()

  for (( i = 0 ; i < $groups ; i++ )); do
    grouplist+=$(
      echo "$((i+1)): ${groupnames[$i]}\n"
      )
  done

  dialog --title "Group list" \
         --no-collapse \
         --msgbox "List of non system groups:\n\
         \n${grouplist//$'\n'/\\n}" 18 25
}

new_group ()
{
  group=$(dialog --title "Add Group" --stdout --inputbox "\nGroup to add:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$group:" /etc/group &> /dev/null
		if [[ $? == 1 ]]; then
			groupadd "$group" &> /dev/null
      exitstatus=$?
			if [[ "$exitstatus" == "0" ]]; then
				dialog --title "SUCCESS" --msgbox "\n\n Group added successfully." 10 30
			elif [[ "$exitstatus"$? == "9" ]]; then
				dialog --title "ERROR" --msgbox "\n\nError, group name not unique." 10 30
			else
				dialog --title "ERROR" --msgbox "\n\n Error creating group." 10 30
			fi
		else
			dialog --title "ERROR" --msgbox "\n\n Group already exists." 10 30
		fi
  fi
}

group_menu ()
{
  groupflag=0

  while [[ $groupflag != 1 ]]; do

    groupoption=$(dialog --title "Group Manager" --stdout --menu "\nPlease select one group action" 15 55 5 \
      AG "Add Group    (Create a new group)" \
      LG "List Groups  (List all user created groups)" \
      VG "View Group   (View group members)" \
      AU "Add User     (Add user to group)" \
      RU "Remove User  (Remove user from group)" \
      CG "Change GID   (Change groupID)" \
      DG "Delete Group (Delete a group)" \
      )

    userexitstatus=$?

    if [[ $userexitstatus == 0 ]]; then
      if [[ $groupoption == AG ]]; then
        clear
        new_group
      elif [[ $groupoption == LG ]]; then
        clear
        list_group
      elif [[ $groupoption == VG ]]; then
        clear
        view_group
      elif [[ $groupoption == AU ]]; then
        clear
        add_to_group
      elif [[ $groupoption == RU ]]; then
        clear
        remove_from_group
      elif [[ $groupoption == CG ]]; then
        clear
        change_gid
      else 
        clear
        delete_group
      fi
    else
      groupflag=1
    fi
		clear
  done
}

modify_comment ()
{
  user=$(dialog --title "Modify Comment" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null #Check if user exists.
    if [[ $? == 0 ]]; then
      uid=$(grep "^$user:" /etc/group | cut -d: -f3)
      if [[ "$uid" -ge "1000" ]] && [[ "$uid" -le "60000" ]]; then #Check if user is non login user.
        comment=$(dialog --title "Modify Comment" --stdout --inputbox "\nEnter new comment:" 10 25)
        if [[ $? == 0 ]]; then
          usermod -c "$comment" "$user" #Changing user comment
          if [[ $? == 0 ]]; then
            dialog --title "SUCCESS" --msgbox "\n\n User comment modified." 10 30
          else
            dialog --title "ERROR" --msgbox "\n\nError modifying user comment." 10 30
          fi
        fi
      else
        dialog --title "ERROR" --msgbox "\n\nCan't modify system user." 10 30
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n  User does not exist." 10 30
    fi
  fi
}

modify_uid ()
{
  #ID can't be more than 60000 or less than 1000
  user=$(dialog --title "Modify UID" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    oldid=$(grep "^$user" /etc/passwd | cut -d: -f3)
    newuid=$(dialog --title "Modify UID" --stdout --inputbox "\nEnter new UID:" 10 25)
    if [[ $? == 0 ]]; then
      if [[ "$newuid" -ge "1000" ]] && [[ "$newuid" -le "60000" ]] && [[ "$oldid" -ge "1000" ]] && [[ "$oldid" -le "60000" ]]; then
      grep "^$user:" /etc/passwd &> /dev/null
        if [[ $? == 0 ]]; then
          dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
          if [[ $? == 0 ]]; then
            usermod -u "$newuid" "$user" &> /dev/null
            exitstatus=$?
            if [[ "$exitstatus" == "0" ]]; then
              dialog --title "SUCCESS" --msgbox "\n\n    User ID changed." 10 30
              find / -user "$oldid" -exec chown -h "$user" {} \;
            elif [[ "$exitstatus" == "4" ]]; then
              dialog --title "ERROR" --msgbox "\n\n    User ID taken." 10 30
            else
              dialog --title "ERROR" --msgbox "\n\nCould not change user ID." 10 30
            fi
          else
            dialog --msgbox "\n\n  Modification cancelled." 10 30
          fi
        else 
          dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
        fi
      else
        dialog --title "ERROR" --msgbox "\n  Incorrect user ID.\n\n  Range is 1000-60000." 10 30
      fi
    fi
  fi
}

modify_shell ()
{
  user=$(dialog --title "Modify Shell" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null #Check if user exist
    if [[ $? == 0 ]]; then
      uid=$(grep "^$user:" /etc/passwd | cut -d: -f4)
      if [[ "$uid" -ge "1000" ]] && [[ "$uid" -le "60000" ]]; then
        newshell=$(dialog --title "Modify Shell" --stdout --inputbox "\nEnter absolute PATH:" 10 25)
        if [[ $? == 0 ]]; then
          newshell=$(echo "$newshell" | sed 's/\/$//')  #Removes last '/' if it is part of path
          grep -v "#" /etc/shell | grep "^$newshell" &> /dev/null #Check if shell is valid log in shell
          if [[ $? == 0 ]]; then
            dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
            if [[ $? == 0 ]]; then
              usermod -s "$newshell" "$user" &> /dev/null #Add new shell to user
              if [[ $? == 0 ]]; then
                dialog --title "SUCCESS" --msgbox "\n\n  Shell changed." 10 30
              else
                dialog --title "ERROR" --msgbox "\n\n Error changing shell." 10 30
              fi
            else
              dialog --msgbox "\n\n  Modification cancelled." 10 30
            fi
          else
            dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
          fi
        else
          dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
        fi
      else
        dialog --title "ERROR" --msgbox "\n\nCan't modify system user." 10 30
      fi
    fi
  fi
}

modify_homedirectory ()
{
  user=$(dialog --title "Modify Directory" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newname=$(dialog --title "Modify Directory" --stdout --inputbox "\nNew directory name:" 10 25)
      if [[ $? == 0 ]]; then
        dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
        if [[ $? == 0 ]]; then
          usermod -d /home/"$newname" "$user" &> /dev/null
          if [[ $? == 0 ]]; then
            dialog --title "SUCCESS" --msgbox "\n\n Home directory changed." 10 30
          else
            dialog --title "ERROR" --msgbox "\n\nCouldn't change home directory." 10 30
          fi
        else
          dialog --msgbox "\n\n  Modification cancelled." 10 30
        fi
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
    fi
  fi
}

modify_name ()
{
  user=$(dialog --title "Modify Name" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newname=$(dialog --title "Modify Name" --stdout --inputbox "\nNew user name:" 10 25)
      if [[ $? == 0 ]]; then
        grep "^$newname:" /etc/passwd
        if [[ $? == 1 ]]; then
          dialog --title "User Manager" --yesno "\n\n   Are you sure?" 10 30
            if [[ $? == 0 ]]; then
              usermod -l "$newname" "$user" &> /dev/null
              userchanged=$?
              mv /home/"$user" /home/"$newname" &> /dev/null
              usermod -d /home/"$newname" "$newname" &> /dev/null
              groupmod -n "$newname" "$user" &> /dev/null
              if [[ $userchanged == 0 ]]; then
                dialog --title "SUCCESS" --msgbox "\n\n  Username changed." 10 30
              else
                dialog --title "ERROR" --msgbox "\n\n Error changing username." 10 30
              fi
            else
              dialog --msgbox "\n\n  Modification cancelled." 10 30
            fi
        else
          dialog --title "ERROR" --msgbox "\n\n   Username taken." 10 30
        fi
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n User does not exist." 10 30
    fi
  fi
}

modify_password ()
{
  user=$(dialog --title "Modify Password" --stdout --inputbox "\nUser to modify:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      password1=$(dialog --title "Add User" --stdout --passwordbox "\nPassword:" 10 25)
      if [[ $? == 0 ]]; then
        password2=$(dialog --title "Add User" --stdout --passwordbox "\nRepeat password:" 10 25)
        if [[ $? == 0 ]]; then
          if [[ "$password1" == "$password2" ]]; then
            echo "$user:$password1" | chpasswd &> /dev/null
            if [[ $? == 0 ]]; then
              dialog --title "SUCCESS" --msgbox "\n\n   Password changed." 10 30
            else
              dialog --title "ERROR" --msgbox "\n\nFailed to Change password." 10 30
            fi
          else
            dialog --title "ERROR" --msgbox "\n\nPasswords does not match,\nuser not created." 10 30
          fi
        fi
      fi
    else
      dialog --msgbox "\n\nUser does not exist." 10 30
    fi
  fi
}

modify_user ()
{
  modifyoption=$(dialog --title "User Manager" --stdout --menu "\nPlease selct one modify action" 14 60 5 \
    MN "Modify Name       (Change name of the user)" \
    MP "Modify Password   (Change password of a user)" \
    MD "Modify Directory  (Change user home directory)" \
    MS "Modify Shell      (Change standard shell)" \
    MU "Modify UID        (Change user ID)" \
    MC "Modify Comment    (Change user comment)" \
    )

  modify=$?

  if [[ $modify == 0 ]]; then
    if [[ $modifyoption == MN ]]; then
      clear
      modify_name
    elif [[ $modifyoption == MP ]]; then
      clear
      modify_password
    elif [[ $modifyoption == MD ]]; then
      clear
      modify_homedirectory
    elif [[ $modifyoption == MS ]]; then
      clear
      modify_shell
    elif [[ $modifyoption == MU ]]; then
      clear
      modify_uid
    else
      clear
      modify_comment
    fi
  fi
}

view_user ()
{
  user=$(dialog --title "View User" --stdout --inputbox "\nUser to view:" 10 25)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/nul
    if [[ $? == 0 ]]; then

    uid=$(grep "^$user" /etc/passwd | cut -d: -f3)
    gid=$(grep "^$user" /etc/passwd | cut -d: -f4)
    directory=$(grep "^$user" /etc/passwd | cut -d: -f6)
    shell=$(grep "^$user" /etc/passwd | cut -d: -f7)
    groups=$(grep "$user\|$uid" /etc/group | cut -d: -f1 | tr '\n' ' ')
    password=$(grep "^$user" /etc/passwd | cut -d: -f2)
    comment=$(grep "^$user" /etc/passwd | cut -d: -f5)

    userinfo=$(
      echo "User name:            $user"
      echo "User ID:              $uid"
      echo "GroupID:              $gid"
      echo "Password:             $password"
      echo "Home directory:       $directory"
      echo "Comment:              $comment"
      echo "Shell PATH:           $shell\n"
      echo "Group memberships:"
      echo "$groups"
    )

    dialog --title "User Information" \
           --no-collapse \
           --msgbox "Information about $user:\n\
           \n${userinfo//$'\n'/\\n}" 19 50

    else
      dialog --msgbox "\n\n   User does not exist." 10 30
    fi
  fi
}

list_users ()
{
  declare -a usernames
  readarray -t usernames < <(awk -F: '$3 >= 1000 && $3<=60000 {print $1}' /etc/passwd)
  users=${#usernames[@]}
  userlist=()

  for (( i = 0 ; i < $users ; i++ )); do
    userlist+=$(
      echo "$((i+1)): ${usernames[$i]}\n"
      )
  done

  dialog --title "User list" \
         --no-collapse \
         --msgbox "List of non system users:\n\
         \n${userlist//$'\n'/\\n}" 18 25
}

delete_user ()
{
  user=$(dialog --title "Delete User" --stdout --inputbox "\nUser to delete:" 10 25)
  if [[ $? == 0 ]]; then
    if [[ "$user" != "$SUDO_USER" ]]; then  #Can't delete the user that started the script.
      dialog --title "User Manager" --yesno "\n\n    Are you sure?" 10 30
      if [[ $? == 0 ]]; then
        userdel -r "$user"  &> /dev/null #Deletes user.
        exitstatus=$?
        if [[ "$exitstatus" == "0" ]]; then
          dialog --title "SUCCESS" --msgbox "\n\nUser deleted successfully." 10 30
        elif [[ "$exitstatus"$? == "1" ]]; then
          dialog --title "ERROR" --msgbox "\nFailed to delete user, \ncouldnt update password file." 10 30
        elif [[ "$exitstatus" == "6" ]]; then
          dialog --title "ERROR" --msgbox "\nFailed to delete user, \nuser doesn't exist." 10 30
        elif [[ "$exitstatus" == "8" ]]; then
          dialog --title "ERROR" --msgbox "\nFailed to delete user, \nuser currently logged in." 10 30
        elif [[ "$exitstatus"$? == "10" ]]; then
          dialog --title "ERROR" --msgbox "\nFailed to delete user, \ncouldnt update group file." 10 30
        elif [[ "$exitstatus"$? == "12" ]]; then
          dialog --title "ERROR" --msgbox "\nFailed to delete user, \ncouldnt remove home directory." 10 30
        else
          dialog --title "ERROR" --msgbox "\n  Failed to delete user." 10 30
        fi
      else
        dialog --msgbox "\n\n  User delition cancelled" 10 30
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n  Cant delete own user." 10 30
    fi
  fi
}

new_user ()
{
  user=$(dialog --title "Add User" --stdout --inputbox "\nUser to add:" 10 25)
  if [[ $? == 0 ]]; then
    if ! grep "^$user:" /etc/passwd &> /dev/null; then
      password1=$(dialog --title "Add User" --stdout --passwordbox "\nPassword:" 10 25)
      if [[ $? == 0 ]]; then
        password2=$(dialog --title "Add User" --stdout --passwordbox "\nRepeat password:" 10 25)
        if [[ $? == 0 ]]; then
          if [[ $password1 == $password2 ]]; then
            useradd -p "$(openssl passwd -1 "$password1")" -md /home/"$user" "$user" &> /dev/null
            exitstatus=$?
            if [[ "$exitstatus" == "0" ]]; then
              dialog --title "SUCCESS" --msgbox "\n\n  User added successfully" 10 30
            elif [[ "$exitstatus" == "1" ]]; then
              dialog --title "ERROR" --msgbox "\nError creating user, \ncant update password file." 10 30
            elif [[ "$exitstatus" == "10" ]]; then
              dialog --title "ERROR" --msgbox "\nError creating user, \ncan't update group file." 10 30
            elif [[ "$exitstatus" == "12" ]]; then
              dialog --title "ERROR" --msgbox "\nError creating user, \ncan't create home directory." 10 30
            else
              dialog --title "ERROR" --msgbox "\n\n   Error creating user." 10 30
            fi
            usermod -s /bin/bash "$user"  &> /dev/null
          else
            dialog --msgbox "\nPasswords does not match, \nuser not created." 10 30
          fi
        fi
      fi
    else
      dialog --title "ERROR" --msgbox "\n\n  User already exists." 10 30
    fi
  fi
}

user_menu ()
{
  userflag=0

  while [[ $userflag != 1 ]]; do

    useroption=$(dialog --title "User Manager" --stdout --menu "Please select one user action" 12 47 20 \
      AU "Add User     (Create a new user)" \
      LU "List Users   (List all login users)" \
      VU "View User    (View user properties)" \
      MU "Modify User  (Modify user properties)" \
      DU "Delete User  (Delete a login user)" \
      )

    userexitstatus=$?

    if [[ $userexitstatus == 0 ]]; then
      if [[ $useroption == AU ]]; then
        clear
        new_user
      elif [[ $useroption == LU ]]; then
        clear
        list_users
      elif [[ $useroption == VU ]]; then
        clear
        view_user
      elif [[ $useroption == MU ]]; then
        clear
        modify_user
      else 
        clear
        delete_user
      fi
    else
      userflag=1
    fi
    clear
  done
}

network_info ()
{
  names=$(ls /sys/class/net | grep -v ^lo$)

  for int in $names; do
    interfaces+="$(
    echo "Interface:   $int"
    echo "IP-address:  $(ip addr show | grep 'inet ' | grep "$int" | grep -v ' lo$' | awk '{print $2}')"
    echo "Gateway:     $(ip route | grep default | grep "$int" | awk '{print $3}')"
    echo "MAC:         $(cat /sys/class/net/$int/address)"
    echo "Status:      $(ip addr show | grep 'state UP\|state DOWN\|state UNKNOWN' | grep -v ' lo:' | grep "$int" | awk '{print $9}')\n\n"
    )"
  done

  dialog --title "Network Information" \
         --no-collapse \
         --msgbox "Computer name: $(hostname)\n\
         \n${interfaces//$'\n'/\\n}" 25 40
}

if [[ $(id -u) != 0 ]]; then
  dialog --title "ERROR" --msgbox "\n\n Program needs to be run with sudo." 9 40
  clear
  exit 1
fi

flag=0

while [[ $flag != 1 ]]
do

  option=$(dialog --title "System Manager" --stdout --menu "Please select one action" 11 30 4 \
    N "Network information" \
    G "Group management" \
    U "User management" \
    D "Directory management" \
    )

  if [[ $? == 0 ]]; then
    if [[ $option == N ]]; then
      clear
      network_info
    elif [[ $option == G ]]; then
      clear
      group_menu
    elif [[ $option == U ]]; then
      clear
      user_menu
    else
      clear
      directory_menu
    fi 

  else
    dialog --title "EXIT" --msgbox "\n\n  You exited the program" 10 30
    flag=1
  fi
  clear
done
