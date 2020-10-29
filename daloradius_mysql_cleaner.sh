#!/bin/bash
# Description: Done to keep daloradius with good performance and clean old data

# Essensial data - change according to your environment
USER='radius_cleaner'
PASSWORD='secret'
DB='radius'
LOG="logger -t "daloradius_mysql_cleaner.sh""

# Mysql query - To simplify the shell itself
MYSQL_EXEC="/usr/bin/mysql -u "$USER" -p"$PASSWORD" "$DB" -ss -e"

# Starting to clean old accounting
$LOG "Iniciando limpeza de accounting"
NUMBER_OF_REGISTERS=$($MYSQL_EXEC 'select COUNT(*) from radacct where AcctStartTime <  now() - interval 90 DAY;')
[ "$NUMBER_OF_REGISTERS" ] || NUMBER_OF_REGISTERS=0
$MYSQL_EXEC 'delete from radacct where AcctStartTime <  now() - interval 90 DAY;' \
&& $LOG "Accounting mais antigo que 90 dias removido, $NUMBER_OF_REGISTERS registros afetados" \
|| $LOG "Falhou, favor verificar"
# End of accounting proccess

# Starting to clean staled sessions older than 7 days
$LOG "Iniciando limpexa de staled sessions"
NUMBER_OF_STALED=$($MYSQL_EXEC "select COUNT(*) from radacct where AcctStartTime < now() - interval 7 DAY AND (AcctStopTime='0000-00-00 00:00:00' OR AcctStopTime IS NULL);")
[ "$NUMBER_OF_REGISTERS" ] || NUMBER_OF_STALED=0
$MYSQL_EXEC "delete from radacct where AcctStartTime <  now() - interval 7 DAY AND (AcctStopTime='0000-00-00 00:00:00' OR AcctStopTime IS NULL);" \
&& $LOG "Staled sessions mais antigas que 7 dias removidas: $NUMBER_OF_STALED" \
|| $LOG "Falhou, favor verificar"
# End of staled sessions cleaning proccess
