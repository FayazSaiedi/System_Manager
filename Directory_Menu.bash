#!/bin/bash
modify_directory ()
{
  folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select what you want to modify:" 12 63 4 \
  MN "Modify Name         (Create a new directory)" \
  MO "Modify Owner        (View content in a directory)" \
  MG "Modify Group        (View directory properties)" \
  DD "Modify Permissions  (Modify directory permissions)" \
  )
  
  if [[ $? == 0 ]]; then
    if [[ $folderoption == MN ]]; then
      name=$(dialog --title "" --stdout --inputbox "\nName to change to:" 10 25)
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
    elif [[ $folderoption == MO ]]; then
        ownername=$(dialog --title "" --stdout --inputbox "\nName to change to:" 10 25)
        if [[ $? == 0 ]]; then
        sudo chown $ownername $1 
        fi
        if [[ $? == 0 ]]; then
            dialog --title "SUCCESS" --msgbox "\n\nOwnership changed." 10 30
        else
           dialog --title "ERROR" --msgbox "\n\nCould not change ownership." 10 30
        fi
    elif [[ $folderoption == MG ]]; then
        groupname=$(dialog --title "" --stdout --inputbox "\nName to change to:" 10 25)
        if [[ $? == 0 ]]; then
        sudo chgrp $groupname $1
        fi
        if [[ $? == 0 ]]; then
            dialog --title "SUCCESS" --msgbox "\n\nGroup Ownership changed." 10 30
        else
           dialog --title "ERROR" --msgbox "\n\nCould not change group ownership." 10 30
        fi

    else
        permissionsop=$(dialog --title "Directory Manger" --stdout --menu "Please select what you want to modify:" 12 63 4 \
        U "USER" \
        G "Group" \
        O "Others" \
        
        )
         if [[ $? == 0 ]]; then
             if [[ $permissionsop == U ]]; then  
                 User1=$(dialog --checklist --stdout "Choose user permisssion:" 15 40 5 \
                  1 Read-only off \
                  2 Write-only off \
                  3 Execute off \
                  4 Setuid-on off \
                
                  )

                    if [[ $? == 0 ]]; then
                       chmod u-rwxs $1
                       
                        for arg in $User1; 
                        do
                          if [[ $arg == 1 ]]; then
                          chmod u+r $1
                          fi
                          if [[ $arg == 2 ]]; then 
                          chmod u+w $1
                          fi
                          if [[ $arg == 3 ]]; then 
                          chmod u+x $1 
                          fi
                          if [[ $arg == 4 ]]; then 
                          chmod u+s $1
                          fi
                  
                        done
                      fi
                fi

             if [[ $permissionsop == G ]]; then 
                  Group=$(dialog --checklist --stdout "choose a group permission" 15 40 5 \
                  1 Readg-only off \
                  2 Write-only off \
                  3 Execute off \
                  4 Setgid-on off \
                  )
                  if [[ $? == 0 ]]; then
                       chmod g-rwx $1
                        for arg in $Group; 
                        do
                          if [[ $arg == 1 ]]; then
                          chmod g+r $1
                          fi
                          if [[ $arg == 2 ]]; then 
                          chmod g+w $1
                          fi
                          if [[ $arg == 3 ]]; then 
                          chmod g+x $1 
                          fi
                        
                          if [[ $arg == 4 ]]; then 
                          chmod g+s $1
                          fi
                        done
                    fi

               fi

              if [[ $permissionsop == O ]]; then 
                   Others=$(dialog --checklist --stdout "choose a others permission" 15 40 5 \
                  1 Readg-only off \
                  2 Write-only off \
                  3 Execute off \
                  4 stickybit-on off \
                  )
                  if [[ $? == 0 ]]; then
                       chmod o-rwx $1
                        for arg in $Others; 
                        do
                          if [[ $arg == 1 ]]; then
                          chmod o+r $1
                          fi
                          if [[ $arg == 2 ]]; then 
                          chmod o+w $1
                          fi
                          if [[ $arg == 3 ]]; then 
                          chmod o+x $1 
                          fi
                        
                          if [[ $arg == 4 ]]; then 
                          chmod +t $1
                          fi
                        done
                    fi

               fi
           
           
           fi 



    fi
  fi
} 

directory_list()
{
  dialog --title "List file of directory" --fselect /home/ 50 50
} 



directory_information ()
{
  


 directory=$(dialog --fselect /home/ 30 50 3>&1 1>&2 2>&3)
if [[ $? == 0 ]]; then  
 if test -d "$directory"
  then

   readU=$(ls -alh $directory | grep " \.$" | cut -c2)
   writeU=$(ls -alh $directory | grep " \.$" | cut -c3)
   execU=$(ls -alh $directory | grep " \.$" | cut -c4)
   readG=$(ls -alh $directory | grep " \.$" | cut -c5)
   writeG=$(ls -alh $directory | grep " \.$" | cut -c6)
   execG=$(ls -alh $directory | grep " \.$" | cut -c7)
   readO=$(ls -alh $directory | grep " \.$" | cut -c8)
   writeO=$(ls -alh $directory | grep " \.$" | cut -c9)
   execO=$(ls -alh $directory | grep " \.$" | cut -c10)

   owner=$(ls -alh $directory | grep " \.$" | awk '{print $3}')
   group=$(ls -alh $directory | grep " \.$" | awk '{print $4}')
   modified=$(ls -alh $directory | grep " \.$" | awk '{print $6, $7, $8}')


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
   if [[ $execO == "x" ]]; then
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
   if [[ $execO == "t" || $execO == "T" ]]; then
    stickybit="ON"
   fi
  
   folderinfo=$(
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
    dialog --title "folder Information" \
          --no-collapse \
          --yes-label "Change" \
          --no-label "Menu" \
          --yesno "Information on $select\n\
          \n${folderinfo//$'\n'/\\n}" 19 50
    if [[ $? == 0 ]]; then
        modify_directory $directory
      fi
      

  
   
 else
  dialog --msgbox "\n\n   Folder does not exist." 10 30

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





foldermenu ()
{
 folderoption=$(dialog --title "system Manger" --menu "Please chosse one option" 20 60 4 \
 fa "Add Folder            (Create a new folder)" \
 fl "List Folder           (View content in a folder)" \
 fv "Folder view/modify    (View folder properties)" \
 fd "Folder Delete         (Delete a folder)" \
 3>&1 1>&2 2>&3)
if [[ $? == 0 ]]; then
    if [[ $folderoption == fa ]]; then
    add_directory
      

    elif [[ $folderoption == fl ]]; then
    directory_list



    elif [[ $folderoption == fv ]]; then

    directory_information

    else 
    delete_directory
    fi
fi
}


flag=0

while [[ $flag != 1 ]]
do

  option=$(dialog --title "System Manager" --menu "Please select one action" 11 30 4 \
    n "Network information" \
    g "Group management" \
    u "User management" \
    d "Folder management" \
    3>&1 1>&2 2>&3) #Output omdirigers. Shell redirections. 

  exitstatus=$?

  if [[ $exitstatus == 0 ]]; then
    if [[ $option == n ]]; then
      dialog --msgbox "Network information" 10 30 
    elif [[ $option == g ]]; then
      dialog --msgbox "Group management" 10 30
    elif [[ $option == u ]]; then
      dialog --msgbox "User management" 10 30

    else
     foldermenu
    fi 

  else
    dialog --msgbox "You exited the program" 10 30
    flag=1
  fi
  clear
done
