#!/user/bin/bash
sudo test -d /var/lib/SQL_Bash/ || sudo mkdir /var/lib/SQL_Bash;
sudo test -d /var/lib/SQL_Bash/Default_DB || sudo mkdir /var/lib/SQL_Bash/Default_DB;
echo "Welcome to SQL DBMS using Bash Script";
current_database="Default_DB";
function SHOW
{
	case $1 in
	DATABASES)
		ls /var/lib/SQL_Bash;
		;;
	TABLES)
		ls /var/lib/SQL_Bash/$current_database;
		;;
	esac
}
function CREATE
{
	case $1 in
	DATABASE)
		if test -d /var/lib/SQL_Bash/$2
		then
		echo "Database already exists";
		else
		sudo mkdir -p /var/lib/SQL_Bash/$2;
		fi	
		;;
	TABLE)
		if test -f /var/lib/SQL_Bash/$current_database/$2
		then
		echo "Table already exists";
		else
		Create_Table $2;
		fi		
		;;
	esac
}
function Create_Table
{
sudo touch /var/lib/SQL_Bash/$current_database/$1
sudo touch /var/lib/SQL_Bash/$current_database/.${1}meta
echo "How many columns do you want to enter?"
read columnNumber
while [[ ! $columnNumber =~ ^[0-9] ]];
do
    echo "Please enter number of columns (only numbers allowed)";
    read columnNumber
done
for((i=0;i<$columnNumber;i++))
do
	echo "please enter the name of the column"
	read columnName
	while [[ ! $columnName =~ ^[A-Za-z0-9_]+$ ]];
	do
		echo "only letters,numbers and (_) are allowed";
		read columnName
	done
	echo "please enter the dataType of the column int/text"
	select columnDataType in int text
	do
	case $columnDataType in
	int)	
		echo "$columnName,"int"" | sudo tee -a /var/lib/SQL_Bash/$current_database/.${1}meta
		break;
		;;
	text)
		echo "$columnName,"text"" | sudo tee -a /var/lib/SQL_Bash/$current_database/.${1}meta
		break;
		;;  
	*)
		echo "Please choose int or text only"		
	esac
	done
done
echo "Table $tableName created successfully"
}

function SELECT
{
case $1 in
ALL )
	case $2 in
	FROM)
	if [ -f /var/lib/SQL_Bash/$current_database/$3 ]
	then
		cut -f1 -d, /var/lib/SQL_Bash/$current_database/.$3meta | tr '\n' ' '
		echo " ";
		tr , ' ' < /var/lib/SQL_Bash/$current_database/$3;
	else
			echo "table not found";
	fi
		;;
	esac
	;;
*)
	case $2 in
	FROM)
		case $4 in
		WHERE)
			if [ -f /var/lib/SQL_Bash/$current_database/$3 ]
			then
			table_lines_count=$(wc -l < /var/lib/SQL_Bash/$current_database/.$3meta);
			column_names=($(cut -f1 -d, /var/lib/SQL_Bash/$current_database/.$3meta));
			condition_column_name=$(echo $5 | cut -f1 -d=);
			condition_column_value=$(echo $5 | cut -f2 -d=);
			for((i=0;i<$table_lines_count;i++))
			do
				if [ ${column_names[$i]} = $condition_column_name ]
				then
				condition=$i;
				fi
			done
			for((j=0;j<$table_lines_count;j++))
			do
				if [ ${column_names[$j]} = $1 ]
				then
				echo ${column_names[$j]};
				awk -F "," -v col=$((j+1)) -v cond=$((condition+1)) -v cond_value=$condition_column_value '{if($cond == cond_value)print $col;}' /var/lib/SQL_Bash/$current_database/$3;
				fi
			done
			else
				echo "table not found";
			fi
			;;
		*)
			if [ -f /var/lib/SQL_Bash/$current_database/$3 ]
			then
			table_lines_count=$(wc -l < /var/lib/SQL_Bash/$current_database/.$3meta);
			column_names=($(cut -f1 -d, /var/lib/SQL_Bash/$current_database/.$3meta));
			for((i=0;i<$table_lines_count;i++))
			do
				if [ ${column_names[$i]} = $1 ]
				then
					echo ${column_names[$i]};
					awk -F "," -v col=$((i+1)) '{print $col}' /var/lib/SQL_Bash/$current_database/$3;
				fi
			done
			else
				echo "table not found";
			fi
			;;
		esac
		;;
	*)
		echo "Please use the following syntax: SELECT column_name FROM table_name WHERE column_name=column_value";
		;;
	esac
	;;
esac
}

function DELETE
{
case $1 in
	FROM)
		case $3 in
		WHERE)
			if [ -f /var/lib/SQL_Bash/$current_database/$2 ]
			then
			table_lines_count=$(wc -l < /var/lib/SQL_Bash/$current_database/.$2meta);
			column_names=($(cut -f1 -d, /var/lib/SQL_Bash/$current_database/.$2meta));
			condition_column_name=$(echo $4 | cut -f1 -d=);
			condition_column_value=$(echo $4 | cut -f2 -d=);
			for((i=0;i<$table_lines_count;i++))
			do
				if [ ${column_names[$i]} = $condition_column_name ]
				then
				condition=$i;
				fi
			done
				
			target=$(awk -F "," -v col=$((j+1)) -v cond=$((condition+1)) -v cond_value=$condition_column_value '{if($cond == cond_value)print $0;}' /var/lib/SQL_Bash/$current_database/$2);
			sudo sed -i "/^${target}/d" /var/lib/SQL_Bash/$current_database/$2;
			echo "Record deleted successfully";
			else
				echo "table not found";
			fi
			;;
		esac
		;;
*)
	echo "Please use the following syntax: DELETE FROM table_name WHERE column_name=column_value";
	;;
esac
}

function DROP
{
	case $1 in
	DATABASE)
		sudo rm -r /var/lib/SQL_Bash/$2;
		if [ ! -f /var/lib/SQL_Bash/$2 ]
		then
			echo "Database dropped successfully";
		fi
		;;
	TABLE)
		sudo rm /var/lib/SQL_Bash/$current_database/$2;
		sudo rm /var/lib/SQL_Bash/$current_database/.$2meta;
		if [ ! -f /var/lib/SQL_Bash/$current_database/$2 ]
		then
			echo "Table dropped successfully";
		fi
		;;
	esac
}
function USE
{
	case $1 in
	DATABASE)
		current_database=$2;
		;;
		
	esac
}

function INSERT
{
case $1 in
INTO)
	case $3 in
	VALUES)
		if [ -f /var/lib/SQL_Bash/$current_database/.$2meta ]
		then
		table_lines_count=$(wc -l < /var/lib/SQL_Bash/$current_database/.$2meta);
		column_types=($(cut -f2 -d, /var/lib/SQL_Bash/$current_database/.$2meta));
		counter=0;
		new_line="";
		if (( "($#-3)" <= "$table_lines_count"))
		then
		for item in ${@:4}
		do
		case $item in
		+([0-9]) )
			if  [ "${column_types[$counter]}" = "int" ]
			then
				if [ -z "$new_line" ]
				then
				new_line=$item
				else
				new_line=$new_line","$item;
				fi
			else
				echo "wrong type: $item should be text";
				new_line="";
				break;
			fi
			counter=$counter+1;
			;;
		+([a-zA-Z0-9_]) )
			if [ ${column_types[$counter]} = "text" ]
			then
				if [ -z "$new_line" ]
				then
				new_line=$item
				else
				new_line=$new_line","$item;
				fi
			else
				echo "wrong type: $item should be integer";
				new_line="";
				break;
			fi
			counter=$counter+1;
			;;
		esac		
		done
		else
			echo "values count is more than the number of columns"
		fi
		if [ -n "$new_line" ]
		then
		echo "Values inserted successfully"
		echo "$new_line" | sudo tee -a /var/lib/SQL_Bash/$current_database/$2
		fi
		else
			echo "table not found";
		fi
		;;
	*)
		echo "Please use the following syntax: INSERT INTO (table name) VALUES (value1) (value2) ..";
		;;
	esac
	;;
*)
	echo "Please use the following syntax: INSERT INTO (table name) VALUES (value1) (value2) ..";
	;;
esac
}
while true
do
read -p "$current_database > " statement;
$statement;
done
