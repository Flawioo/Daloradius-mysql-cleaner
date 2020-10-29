# Daloradius-mysql-cleaner
Helps to keep mysql database as clean as possible removing old client staled sessions and old data to maintain server performance

# Info
The user radius_cleaner was created just to execute select and delete in the table radacct of radius database, it ensure some security.

The password is not "secret", please use some random generator to ensure some more security.

The DB for my environment is radius but in your could be diferent, pay attencion at this point

The language used to log was PT-BR from Brazil, you can adjust as you want

```
#!/bin/bash
USER='radius_cleaner'
PASSWORD='secret'
DB='radius'
LOG="logger -t "daloradius_mysql_cleaner.sh""
MYSQL_EXEC="/usr/bin/mysql -u "$USER" -p"$PASSWORD" "$DB" -ss -e"
$LOG "Iniciando limpeza de accounting"
NUMBER_OF_REGISTERS=$($MYSQL_EXEC 'select COUNT(*) from radacct where AcctStartTime <  now() - interval 90 DAY;')
[ "$NUMBER_OF_REGISTERS" ] || NUMBER_OF_REGISTERS=0
$MYSQL_EXEC 'delete from radacct where AcctStartTime <  now() - interval 90 DAY;' \
&& $LOG "Accounting mais antigo que 90 dias removido, $NUMBER_OF_REGISTERS registros afetados" \
|| $LOG "Falhou, favor verificar"

$LOG "Iniciando limpexa de staled sessions"
NUMBER_OF_STALED=$($MYSQL_EXEC "select COUNT(*) from radacct where AcctStartTime < now() - interval 7 DAY AND (AcctStopTime='0000-00-00 00:00:00' OR AcctStopTime IS NULL);")
[ "$NUMBER_OF_REGISTERS" ] || NUMBER_OF_STALED=0
$MYSQL_EXEC "delete from radacct where AcctStartTime <  now() - interval 7 DAY AND (AcctStopTime='0000-00-00 00:00:00' OR AcctStopTime IS NULL);" \
&& $LOG "Staled sessions mais antigas que 7 dias removidas: $NUMBER_OF_STALED" \
|| $LOG "Falhou, favor verificar"
```
