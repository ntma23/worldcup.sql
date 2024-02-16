#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE games, teams")
cat games.csv | while IFS="," read YEAR ROUND W O WG OG
do 
#get opponent id
if [[  $O != opponent ]]
then
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$O'")
#if not found
if [[ -z $TEAM_ID ]]
then 
#insert team name
INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$O')")
if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
then echo Inserted into teams: $O
fi
if [[ $($PSQL "SELECT COUNT(name) FROM teams WHERE name = '$W'") = 0 ]]
then 
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$W'")
INSERT_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$W')")
if [[ $INSERT_TEAM_RESULT == 'INSERT 0 1' ]]
then echo Inserted into teams: $W
fi
fi
#get new team id
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$O'")
fi
fi
done

#GAMES 
cat games.csv | while IFS=',' read YEAR ROUND W O WG OG
do 
#get team id
if [[ $O != opponent ]]
then 
TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$O'")
#if not found
if [[ -z $TEAM_ID ]]
#set to null
then TEAM_ID=null
fi
#insert data
O_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$O'")
W_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$W'")
INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, opponent_id, opponent_goals, winner_id, winner_goals) VALUES($YEAR, '$ROUND', $O_ID, $OG, $W_ID, $WG)")
if [[ $INSERT_GAME_RESULT = 'INSERT 0 1' ]]
then echo Inserted into games: $YEAR, $ROUND, $O, $OG, $W, $WG
fi
fi 
done