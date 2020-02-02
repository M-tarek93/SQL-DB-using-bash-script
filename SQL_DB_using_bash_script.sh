#!/user/bin/bash

sudo test -d /var/lib/SQL_Bash/ || sudo mkdir /var/lib/SQL_Bash;
echo "Welcome to SQL DBMS using Bash Script";

function SHOW
{
	case $1 in
	DATABASES)
		ls /var/lib/SQL_Bash;
		;;
	esac
}
function CREATE
{
	case $1 in
	DATABASE)
		sudo mkdir -p /var/lib/SQL_Bash/$2;
		;;
	esac
}
function DROP
{
	case $1 in
	DATABASE)
		sudo rm -r /var/lib/SQL_Bash/$2;
		;;
	esac
}
while true
do
read statement;
$statement;
done
