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
for((i=0;i<$columnNumber;i++))
do
echo "please enter the name of the column"
read columnName
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
		if [ -f /var/lib/SQL_Bash/$current_database/$3 ]
		then
		table_lines_count=$(wc -l < /var/lib/SQL_Bash/$current_database/.$3meta);
		column_names=($(cut -f1 -d, /var/lib/SQL_Bash/$current_database/.$3meta));
		for((i=0;i<$table_lines_count;i++))
		do
			if [ ${column_names[$i]} = $1 ]
			then
				awk -F "," -v col=$((i+1)) '{print $col}' /var/lib/SQL_Bash/$current_database/$3;
			fi
		done
		else
			echo "table not found";
		fi
		;;
	esac
	;;
esac
}

function Delete
{
echo "please enter row number";
read rowNumber
sed -O '$rowNumber d'  /var/lib/SQL_Bash/$current_database/.${tableName}meta
}

function DROP
{
	case $1 in
	DATABASE)
		sudo rm -r /var/lib/SQL_Bash/$2;
		;;
	TABLE)
		sudo rm /var/lib/SQL_Bash/$current_database/$2;
		sudo rm /var/lib/SQL_Bash/$current_database/.$2meta;
		;;
	esac
}
function USE
{
	case $1 in
	DATABASE)
		
		cd /var/lib/SQL_Bash/$2;
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
