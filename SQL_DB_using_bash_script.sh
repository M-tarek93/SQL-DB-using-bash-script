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
		sudo touch /var/lib/SQL_Bash/$current_database/$2;
		sudo touch /var/lib/SQL_Bash/$current_database/.$2meta
		fi		
		;;
	esac
}
function Create_Table
{

echo "please enter the table name";
read tableName
sudo touch /var/lib/SQL_Bash/$current_database/$tableName
echo "How many columns do you want to enter?"
read columnNumber
for((i=0;i<$columnNumber;i++))
do

#read columnDataType
echo "please enter the name of the column"
read columnName
echo "please enter the dataType of the column int/text"
select columnDataType in int text
do
case $columnDataType in
int)
	sudo touch /var/lib/SQL_Bash/$current_database/.${tableName}meta	
	sudo chmod +x .${tableName}meta
	sudo echo $columnName"int" >> /var/lib/SQL_Bash/$current_database/.${tableName}meta
	
	
	;;
text)
	sudo touch /var/lib/SQL_Bash/$current_database/.${tableName}meta	
	sudo chmod +x .${tableName}meta	
	sudo echo $columnName"text" >> /var/lib/SQL_Bash/$current_database/.${tableName}meta
	
	;;  		
esac
done
done	
}
function Select
{
columnNumber="please enter the column's number"
echo $columnNumber
read columnNumber
if [[ -v $columnNumber ]]
then
    cat -n$columnNumber /var/lib/SQL_Bash/$current_database/.${tableName}meta
else
    echo "the column does not exist!"
}

function Delete
{
rowNumber="please enter row number"
echo $rowNumber
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
while true
do
read -p "$current_database > " statement;
$statement;
done
