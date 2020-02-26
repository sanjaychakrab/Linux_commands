#!/bin/bash
# check system  health

# Sanjay Chakraborty
#
# variable setup
HOSTS=$$
row=2
col=4
TEMP_=$(date +"%m-%d-%Y-%s")
DAILY_REPORT=/var/tmp/daily_report/
if [ ! -d $DAILY_REPORT ];
        then
        mkdir $DAILY_REPORT
fi
# get the name for hosts file. Remove scan /vip and not needed names
#/bin/cat /etc/hosts |egrep 'ptl|ptl2' |awk '{print $2}' |egrep -v 'scan|priv|dac|vip|us|wx|ptl4|ptl3|ptl5|ptl6'  > $HOSTS, prefer to pickup host by ip
/bin/cat /etc/hosts |egrep 'abcptl*' |awk '{print $1}' |egrep -v 'scan|priv|dac|vip|us|wx|ptl4|ptl3|ptl5|ptl6'  > $HOSTS
#### variable setup ends
#better display
COUNTER() {
        display="Working in ${1} ..."
        clear
        tput cup $row $col
        echo -n "$display"
        L=${#display}
        L=$(( L+$col ))
        echo -n "$i"
        sleep 1
        }

function disk_used()
{

for host  in `/bin/cat $HOSTS`;
do
#        COUNTER  "$host"
        echo 'checking df'
        echo 'checking  disk usage in size, inode  status in  ' $host '.....' >>$TEMP_;
        echo "-----------" >>$TEMP_ ;
        ssh -q $host df --o  |sed  '/tmpfs/d' >> $TEMP_ ;
        echo "--------" >> $TEMP_ ;
        echo 'ending df'
done
}
function check_prod_interface_speed()
{
echo 'Collecting port eth0 interface speed in ' >> $TEMP_
for host  in `/bin/cat $HOSTS`;
do
#        COUNTER  "$host"

         echo 'check speed in host '$host '.....' >>$TEMP_
        ssh -q $host /usr/sbin/ethtool  eth0 |egrep -i 'speed|duplex'  1>>$TEMP_ 2>/dev/null
        echo '---------' >> $TEMP_
        echo; >> $TEMP_
        done

}

function CHECK_MEMORY()
{

for host  in `/bin/cat $HOSTS`;
do
#        COUNTER  "$host"
        echo 'Memory status  in ' $host '....' >>$TEMP_;
        echo "-----------" >>$TEMP_ ;
        ssh -q $host /usr/bin/free -h  >> $TEMP_ ;
        echo "--------" >> $TEMP_ ;
done

}

function CHECK_CPU()
{
for host  in `/bin/cat $HOSTS`;
do
#        COUNTER  "$host"
        echo 'Check cpu status  in ' $host '....' >>$TEMP_;
        echo "-----------" >>$TEMP_ ;
        ssh -q $host /usr/bin/mpstat -P ALL  >> $TEMP_ ;
        echo "--------" >> $TEMP_ ;
done
}


check_prod_interface_speed
disk_used
CHECK_MEMORY
CHECK_CPU
/bin/mv $TEMP_ $DAILY_REPORT
 rm $HOSTS
echo
echo "Generated report from all prod hosts for disk usage memory and network speed  and cpu .. .."
echo
echo 'Report in' $DAILY_REPORT$TEMP_
exit $?
