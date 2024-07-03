#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n\nWelcome to My Salon, how can I help you\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
  read SERVICE_ID_SELECTED
  # if service_id_to_choose not a number
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
  then
    # send to main menu
    MAIN_MENU "Input not valid"
    return
  fi

  SERVICE_ID=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  # if service_id not found
  if [[ -z $SERVICE_ID ]]
  then
    # send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
    return
  fi

  # ask for phone number
  echo "What's your phone number"
  read CUSTOMER_PHONE
  # get customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  # if customer not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # ask customer name
    echo "I don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #insert customer info
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
    echo $CUSTOMER_INSERT_RESULT
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
  fi
    # get customer name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID")
    # ask appointment time
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID")
  echo $SERVICE_NAME
  echo "What time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
  read SERVICE_TIME
  echo $SERVICE_TIME
    # insert appointment info
    APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
    echo $APPOINTMENT_INSERT_RESULT
    echo "I have put you down for a$SERVICE_NAME at $SERVICE_TIME,$CUSTOMER_NAME."
}

MAIN_MENU