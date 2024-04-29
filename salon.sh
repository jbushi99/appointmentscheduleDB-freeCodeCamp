#!/bin/bash
echo -e "\n***** SALON APPOINTMENT SCHEDULER *****\n"
PSQL="psql --username=freecodecamp --dbname=salon -t -c"

SERVICES(){
  SERVICES_LIST="$($PSQL "SELECT service_id, name, price_$ FROM services;")"
  echo "$SERVICES_LIST" | while IFS='|' read ID NAME PRICE
  do
    echo "$(echo $ID | sed 's/ //'))$NAME" 
  done
  PICK_SERVICE
}

PICK_SERVICE(){
  echo -e "\nPlease, pick a service: "
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [1-4] ]]
  then
    echo -e "\nInvalid choice! Please pick a service:\n"
    SERVICES
  else
    MANAGE_SERVICE
  fi
}

MANAGE_SERVICE(){
  echo -e "\nPlease, provide a phone number: "
  read CUSTOMER_PHONE
  CUSTOMER_PHONE_QRESULT=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE';")
  if [[ -z $CUSTOMER_PHONE_QRESULT ]]
  then
    echo -e "\nPlease, enter your name: "
    read CUSTOMER_NAME
    echo "$($PSQL "INSERT INTO customers(phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")"
  fi
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  echo -e "\nPlease, enter the desired time of the appointment: "
  read SERVICE_TIME
  echo "$($PSQL "INSERT INTO appointments(time, customer_id, service_id) VALUES ('$SERVICE_TIME', $CUSTOMER_ID, $SERVICE_ID_SELECTED)")"

  SERVICE_SELECTED=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")
  
  echo "I have put you down for a $(echo $SERVICE_SELECTED | sed 's/ //') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed 's/ //')."
}

SERVICES
