#!/bin/bash

modify_comment ()
{
  user=$(dialog --title "Modify Comment" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      comment=$(dialog --title "Modify Comment" --inputbox "\nEnter new comment:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        usermod -c "$comment" "$user"
        if [[ $? == 0 ]]; then
          dialog --msgbox "\n\nUser comment modified." 10 30
        else
          dialog --msgbox "\n\nError modifying user comment." 10 30
        fi
      fi
    else
      dialog --msgbox "\n\nUser does not exist." 10 30
    fi
  fi
}

modify_uid ()
{
  user=$(dialog --title "Modify UID" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    oldid=$(grep "^$user" /etc/passwd | cut -d: -f3)
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newuid=$(dialog --title "Modify UID" --inputbox "\nEnter new UID:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        usermod -u "$newuid" "$user" &> /dev/null
        if [[ $? == 0 ]]; then
          dialog --msgbox "\n\nUser ID changed." 10 30
          find / -user "$oldid" -exec chown -h "$user" {} \;
        elif [[ $? == 4 ]]; then
          dialog --msgbox "\n\nUser ID taken." 10 30
        else
          dialog --msgbox "\n\nCould not change user ID." 10 30
        fi
      fi
    else 
      dialog --msgbox "\n\nUser does not exist." 10 30
    fi
  fi
}

modify_shell ()
{
  user=$(dialog --title "Modify Shell" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newshell=$(dialog --title "Modify Shell" --inputbox "\nEnter absolute PATH:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        usermod -s "$newshell" "$user" &> /dev/null
        if [[ $? == 0 ]]; then
          dialog --msgbox "\n\nShell changed." 10 30
        else
          dialog --msgbox "\n\nError changing shell." 10 30
        fi
      else
        dialog --msgbox "\n\nUser does not exist." 10 30
      fi
    fi
  fi
}

modify_directory ()
{
  user=$(dialog --title "Modify Directory" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newname=$(dialog --title "Modify Directory" --inputbox "\nNew directory name:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        usermod -md /home/"$newname" "$user" &> /dev/null
        if [[ $? == 0 ]]; then
          dialog --msgbox "\n\nHome directory changed." 10 30
        else
          dialog --msgbox "\n\nCouldn't change home directory." 10 30
        fi
      fi
    else
      dialog --msgbox "\n\nUser does not exist." 10 30
    fi
  fi
}

modify_name ()
{
  user=$(dialog --title "Modify Name" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      newname=$(dialog --title "Modify Name" --inputbox "\nNew user name:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        grep "^$newname:" /etc/passwd
        if [[ $? == 1 ]]; then
          usermod -l "$newname" "$user" &> /dev/null
          userchanged=$?
          mv /home/"$user" /home/"$newname" &> /dev/null
          usermod -d /home/"$newname" "$newname" &> /dev/null
          groupmod -n "$newname" "$user" &> /dev/null
          if [[ $userchanged == 0 ]]; then
            dialog --msgbox "\n\nUsername changed." 10 30
          else
            dialog --msgbox "\n\nError changing username." 10 30
          fi
        else
          dialog --msgbox "\n\nUsername taken." 10 30
        fi
      fi
    else
      dialog --msgbox "\n\nUser does not exist." 10 30
    fi
  fi
}

modify_password ()
{
  user=$(dialog --title "Modify Password" --inputbox "\nUser to modify:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null
    if [[ $? == 0 ]]; then
      password1=$(dialog --title "Add User" --passwordbox "\nPassword:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        password2=$(dialog --title "Add User" --passwordbox "\nRepeat password:" 10 25 3>&1 1>&2 2>&3)
        if [[ $? == 0 ]]; then
          if [[ "$password1" == "$password2" ]]; then
            echo "$user:$password1" | chpasswd &> /dev/null
            if [[ $? == 0 ]]; then
              dialog --msgbox "\n\nPassword changed." 10 30
            else
              dialog --msgbox "\n\nFailed to Change password." 10 30
            fi
          else
            dialog --msgbox "Passwords does not match, user not created." 10 30
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
  modifyoption=$(dialog --title "User Manager" --menu "\nPlease selct one user action" 14 60 5 \
    MN "Modify name       (Change name of the user)" \
    MP "Modify password   (Change password of a user)" \
    MD "Modify directory  (Change user home directory)" \
    MS "Modify shell      (Change standard shell)" \
    MU "Modify UID        (Change user ID)" \
    MC "Modify Comment    (Change user comment)" \
    3>&1 1>&2 2>&3)

  modify=$?

  if [[ $modify == 0 ]]; then
    if [[ $modifyoption == MN ]]; then
      modify_name
    elif [[ $modifyoption == MP ]]; then
      modify_password
    elif [[ $modifyoption == MD ]]; then
      modify_directory
    elif [[ $modifyoption == MS ]]; then
      modify_shell
    elif [[ $modifyoption == MU ]]; then
      modify_uid
    else
      modify_comment
    fi
  fi
}

view_user ()
{
  user=$(dialog --title "View User" --inputbox "User to view:" 10 25 3>&1 1>&2 2>&3)
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
  readarray -t usernames < <(awk -F: '$3 >= 1000 {print $1}' /etc/passwd)
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
  user=$(dialog --title "Delete User" --inputbox "User to delete:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
  dialog --yesno "You sure you want to delete $user?" 10 30
    if [[ $? == 0 ]]; then
      userdel -r "$user"  &> /dev/null
      if [[ $? == 0 ]]; then
        dialog --msgbox "User deleted successfully." 10 30
      elif [[ $? == 1 ]]; then
        dialog --msgbox "Failed to delete user, couldnt update password file." 10 30
      elif [[ $? == 6 ]]; then
        dialog --msgbox "Failed to delete user, user doesn't exist." 10 30
      elif [[ $? == 8 ]]; then
        dialog --msgbox "Failed to delete user, user currently logged in." 10 30
      elif [[ $? == 10 ]]; then
        dialog --msgbox "Failed to delete user, couldnt update group file." 10 30
      elif [[ $? == 12 ]]; then
        dialog --msgbox "Failed to delete user, couldnt remove home directory." 10 30
      else
        dialog --msgbox "Failed to delete user." 10 30
      fi
    else
      dialog --msgbox "User delition cancelled" 10 30
    fi
  fi
}

new_user ()
{
  user=$(dialog --title "Add User" --inputbox "User to add:" 10 25 3>&1 1>&2 2>&3)
  if [[ $? == 0 ]]; then
    grep "^$user:" /etc/passwd &> /dev/null # för att kolla om det finns redan en user på samma namn
    if [[ $? == 1 ]]; then
      password1=$(dialog --title "Add User" --passwordbox "Password:" 10 25 3>&1 1>&2 2>&3)
      if [[ $? == 0 ]]; then
        password2=$(dialog --title "Add User" --passwordbox "Repeat password:" 10 25 3>&1 1>&2 2>&3)
        if [[ $? == 0 ]]; then
          if [[ $password1 == $password2 ]]; then
            useradd -p "$(openssl passwd -1 "$password1")" -md /home/"$user" "$user" &> /dev/null
            if [[ $? == 0 ]]; then
              dialog --msgbox "User added successfully" 10 30
            elif [[ $? == 1 ]]; then
              dialog --msgbox "Error creating user, cant update password file." 10 30
            elif [[ $? == 10 ]]; then
              dialog --msgbox "Error creating user, can't update group file." 10 30
            elif [[ $? == 12 ]]; then
              dialog --msgbox "Error creating user, can't create home directory." 10 30
            else
              dialog --msgbox "Error creating user." 10 30
            fi
            usermod -s /bin/bash "$user"  &> /dev/null
          else
            dialog --msgbox "Passwords does not match, user not created." 10 30
          fi
        else
          dialog --msgbox "User already exists." 10 30
        fi
      fi
    fi
  fi
}

user_menu ()
{
  userflag=0

  while [[ $userflag != 1 ]]; do

    useroption=$(dialog --title "User Manager" --menu "\nPlease selct one user action" 13 55 5 \
      AU "Add User     (Create a new user)" \
      LU "List Users   (List all login users)" \
      VU "View User    (View user properties)" \
      MU "Modify User  (Modify user properties)" \
      DU "Delete User  (Delete a login user)" \
      3>&1 1>&2 2>&3)

    userexitstatus=$?

    if [[ $userexitstatus == 0 ]]; then
      if [[ $useroption == AU ]]; then
        new_user
      elif [[ $useroption == LU ]]; then
        list_users
      elif [[ $useroption == VU ]]; then
        view_user
      elif [[ $useroption == MU ]]; then
        modify_user
      else 
        delete_user
      fi
    else
      userflag=1
    fi
  done
}