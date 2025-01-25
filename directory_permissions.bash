#!/bin/bash

modify_directory_name ()
{
  name=$(dialog --title "" -stdout --inputbox "\nUser to add:" 10 25)
  if [[ $? == 0 ]]; then
    path=$(pwd)
    if [[ -d $path$name ]]; then
      dialog --title "SUCCESS" --msgbox "\n\nCould not create directory." 10 30
    else
      dialog --title "ERROR" --msgbox "\n\n Directory name taken." 10 30
    fi
  fi
}

modify_directory ()
{
  folderoption=$(dialog --title "Directory Manger" --stdout --menu "Please select what you want to modify:" 12 63 4 \
  MN "Modify Name         (Change name of the directory)" \
  MO "Modify Owner        (Change owner of the directory)" \
  MG "Modify Group        (Change group ownership)" \
  MP "Modify Permissions  (Modify the directory permissions)" \
  )
  
  if [[ $? == 0 ]]; then
    if [[ $folderoption == MN ]]; then
        echo "hej"
    elif [[ $folderoption == MO ]]; then
        echo "hej"
    elif [[ $folderoption == MG ]]; then
        echo "hej"
    else
        echo "hej"
    fi
  fi
}

modify_directory