
#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

CSV_FILE="games.csv"

IFS=',' read -r -a headers < "$CSV_FILE"
echo "Headers: ${headers[@]}"

while IFS=',' read -r -a row
do
	if [ "${row[0]}" != "${headers[0]}" ]; then
		for i in "${!row[@]}"; do
			printf "%s: %s\n" "${headers[$i]}" "${row[$i]}"
			if [[ ${headers[$i]} == "year" ]]; then
                year=${row[$i]} 
            fi
			if [[ ${headers[$i]} == "round" ]]; then
                round=${row[$i]} 
            fi
			if [[ ${headers[$i]} == "winner" ]]; then
			    # printf "%s: %s\n" "${headers[$i]}" "${row[$i]}"
                $PSQL "INSERT INTO teams (name) VALUES ('${row[$i]}') ON CONFLICT (name) DO NOTHING;"
                winner_id=$($PSQL "SELECT team_id from teams where name='${row[$i]}';")
            fi
			if [[ ${headers[$i]} == "opponent" ]]; then
                $PSQL "INSERT INTO teams (name) VALUES ('${row[$i]}') ON CONFLICT (name) DO NOTHING;"
                opponent_id=$($PSQL "SELECT team_id from teams where name='${row[$i]}';")
            fi
			if [[ ${headers[$i]} == "winner_goals" ]]; then
                winner_goals=${row[$i]} 
            fi
			if [[ ${headers[$i]} == "opponent_goals" ]]; then
                opponent_goals=${row[$i]} 
            fi

		done

        $PSQL "INSERT INTO games (year,round,winner_id,opponent_id,winner_goals,opponent_goals) VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals);"
		echo "---"
	fi
done < "$CSV_FILE"
