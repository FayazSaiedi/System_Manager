#!/bin/bash

option=$(dialog --menu "choose an option" 10 30 3 \
  1 "Option 1" \
  2 "Option 2" \
  3 "Option 3" \
  3>&1 1>&2 2>&3)
  
exitstatus=$?

clear
  
if [[ $exitstatus == 0 ]]; then
  dialog --msgbox "You selected: $option" 10 30
    
else
  echo "You cancelled the dialog."
fi

dialog --menu "choose an option" 10 30 3 \
  1 "Option 1" \
  2 "Option 2" \
  3 "Option 3" \
  3>&1 1>&2 2>&3

dialog --msgbox "You selected: $option" 10 30 