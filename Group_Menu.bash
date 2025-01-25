#!/bin/bash

add_to_group ()
{
	user=$(dialog --title "Add To Group" --inputbox "\nUser to add:" 10 25 3>&1 1>&2 2>&3)
	if [[ $? == 0 ]]; then
		grep "^$user" /etc/passwd &> /dev/null
		if [[ $? == 0 ]]; then
			group=$(dialog --title "Add To Group" --inputbox "\nGroup to add to:" 10 25 3>&1 1>&2 2>&3)
			if [[ $? == 0 ]]; then
				grep "^$group" /etc/group &> /dev/null
				if [[ $? == 0 ]]; then
					usermod -aG "$group" "$user"
					if [[ $? == 0 ]]; then
						dialog --msgbox "\n\nUser added to group." 10 30
					else
						dialog --msgbox "\n\nError adding user." 10 30
					fi
				else
					dialog --msgbox "\n\Group doesn't exist." 10 30
				fi
			fi
		else
		dialog --msgbox "\n\nUser doesn't exist." 10 30
		fi
	fi
}

view_group ()
{
  group=$(dialog --title "View Group" --inputbox "\nGroup to view:" 10 25 3>&1 1>&2 2>&3)
	members=$(grep "^$group" /etc/group | cut -d: -f4)
	grep "^$group:" /etc/passwd &> /dev/null
	if [[ $? == 0 ]]; then
		members+=$(echo "$group")
	fi
	count=${#members[@]}
  memberlist=()

  for (( i = 0 ; i < $count ; i++ )); do
    memberlist+=$(
      echo "$((i+1)): ${members[$i]}\n"
      )
  done
	if [[ $? == 0 ]]; then
		grep "^$group:" /etc/group &> /dev/null
		if [[ $? == 0 ]]; then
			dialog --title "View Group" --msgbox "\nMembers in group $group:\n\n${grouplist//$'\n'/\\n}" 18 25
		else
		  dialog --msgbox "\n\nGroup doesn't exist." 10 30
		fi
	fi
}

delete_group ()
{
	group=$(dialog --title "Delete Group" --inputbox "\nGroup to delete:" 10 25 3>&1 1>&2 2>&3)
	if [[ $? == 0 ]]; then
		grep "^$group:" /etc/group &> /dev/null
		if [[ $? == 0 ]]; then
		  groupdel "$group" &> /dev/null
			if [[ $? == 0 ]]; then
				dialog --msgbox "\n\nGroup deleted." 10 30
			else
				dialog --msgbox "\n\nError deleting group." 10 30
			fi
		else
		  dialog --msgbox "\n\nGroup doesn't exist." 10 30
		fi
	fi
}

list_group ()
{
  declare -a groupnames
  readarray -t groupnames < <(awk -F: '$3 >= 1000 {print $1}' /etc/group | grep -v "^nogroup")
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
  group=$(dialog --title "Add Group" --inputbox "Group to add:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$group:" /etc/group &> /dev/null
		if [[ $? == 1 ]]; then
			groupadd $group &> /dev/null
			if [[ $? == 0 ]]; then
				dialog --msgbox "\n\nGroup added successfully." 10 30
			elif [[ $? == 9 ]]; then
				dialog --msgbox "\n\nError, group name not unique." 10 30
			else
				dialog --msgbox "\n\nError creating group." 10 30
			fi
		else
			dialog --msgbox "\n\nGroup already exists." 10 30
		fi
  fi
}

group_menu ()
{
  groupflag=0

  while [[ $groupflag != 1 ]]; do

    useroption=$(dialog --title "Group Manager" --menu "\nPlease selct one group action" 13 55 5 \
      AG "Add Group    (Create a new group)" \
      LG "List Groups  (List all user created groups)" \
      VG "View Group   (View group members)" \
      MG "Add User     (Add user to group)" \
      DG "Delete Group (Delete a group)" \
      3>&1 1>&2 2>&3)

    userexitstatus=$?

    if [[ $userexitstatus == 0 ]]; then
      if [[ $useroption == AG ]]; then
        new_group
      elif [[ $useroption == LG ]]; then
        list_group
      elif [[ $useroption == VG ]]; then
        view_group
      elif [[ $useroption == MG ]]; then
        add_to_group
      else 
        delete_group
      fi
    else
      groupflag=1
    fi
		clear
  done
}

group_menu