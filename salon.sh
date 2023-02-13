#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

ASK_TIME() {
    echo -e "\nWhen would you like to schedule an appointment?"
    read SERVICE_TIME
}

SERVICE_MENU() {
  # display a numbered list of the services
  echo -e "\n~~Service Menu~~\n"

  echo -e "What service would you like\n?"

  echo "$($PSQL "SELECT * FROM services")" | while read SERVICE_ID BAR NAME
  do
    if [[ $SERVICE_ID != 'service_id' ]]
    then
      echo "$SERVICE_ID) $NAME"
    fi
  done

  read SERVICE_ID_SELECTED
  SERVICE_SELECTED_INFO="$($PSQL "SELECT * FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
  if [[ -z $SERVICE_SELECTED_INFO ]]
  then
    SERVICE_MENU
  else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    
    # if customer is new
    if [[ -z $CUSTOMER_ID ]]
    then
      echo -e "\nWhat is your name?"
      read CUSTOMER_NAME
      ASK_TIME
      
      # insert new customer info
      NEW_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")

      # update customer_id
      CUSTOMER_ID="$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    else
      ASK_TIME
      CUSTOMER_NAME="$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")"
    fi
    
    # registering the appointment
    NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    # final message
    SERVICE_SELECTED="$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")"
    echo "I have put you down for a $SERVICE_SELECTED at $SERVICE_TIME, $CUSTOMER_NAME." | sed 's/  / /g'
  fi
}

SERVICE_MENU

