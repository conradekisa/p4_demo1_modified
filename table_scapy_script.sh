#!/bin/bash

#Script written by Conrad

#This script must be run after running install_grpc.sh
#This script must be run in a different terminal from the install_grpc.sh terminal
echo "---------------------------------"
echo "THIS SCRIPT SHALL UPDATE THE TABLES FOR THE DEMO1.P4_14.P4 PROGRAM AND RUN "
echo "RUN SCAPY TESTS AGAINST THIS TABLE ENTRIES"
echo ""
echo "---------------------------------"
echo ""
echo ""


#This creates the default action table entries in simple_switch_CLI
echo "table_set_default ipv4_da_lpm my_drop" | simple_switch_CLI
echo "table_set_default mac_da my_drop" | simple_switch_CLI
echo "table_set_default send_frame my_drop" | simple_switch_CLI

#This adds entries into the predefined tables in the demo1.p4_16.p4 program
echo "-----------------------------------"
echo "ADD ENTRIES INTO THE TABLE ENTRIES IN DEMO1.P4_16.P4"
echo ""
echo "table_add ipv4_da_lpm set_12ptr 10.1.0.1/32 => 58" | simple_switch_CLI
echo "table_add mac_da set_bd_dmac_intf 58 => 9 02:13:57:ab:cd:ef 2" | simple_switch_CLI
echo "table_add send_frame rewrite_mac 9 => 00:11:22:33:44:55" | simple_switch_CLI

echo "table_add ipv4_da_lpm set_l2ptr 10.1.0.200/32 => 81" | simple_switch_CLI
echo "table_add mac_da set_bd_dmac_intf 81 => 15 08:de:ad:be:ef:00 4" | simple_switch_CLI
echo "table_add send_frame rewrite_mac 15 => ca:fe:ba:be:d0:0d" | simple_switch_CLI
echo ""
echo ""

#This checks the table entries in the tables below
echo "-----------------------------------"
echo "CHECK TABLE ENTRIES"
echo ""
echo "Table Dump for ipv4_da_lpm..."
echo ""
echo "table_dump ipv4_da_lpm" | simple_switch_CLI
echo ""
echo "Table dump for mac_da......"
echo ""
echo "table_dump mac_da" | simple_switch_CLI
echo ""
echo ""
#This creates packets in scapy that can be used to perform tests against the simple_switch_CLI
echo "-----------------------------------"
echo "CREATE TEST PACKETS IN SCAPY"
echo ""
echo "fwd_pkt1=Ether() / IP(dst='10.1.0.1') / TCP(sport=5793, dport=80)" | sudo scapy 2> logs.log
rm -r logs.log
echo "fwd_pkt1 packet created..."
echo "drop_pkt1=Ether() / IP(dst='10.1.0.34') / TCP(sport=5793, dport=80)" | sudo scapy 2> logs.log
rm -r logs.log
echo "drop_pkt1 packet created..."
echo "fwd_pkt2=Ether() / IP(dst='10.1.0.1') / TCP(sport=5793, dport=80) / Raw('The quick brown fox jumped over the lazy dog.')" | sudo scapy 2> logs.log
rm -r logs.log
echo "fwd_pkt2 packet created..."

#This tests to see if the packets can be sent successfully or not;given the existing configurations. Change the ip addresses of
#any of the commands to see what happens if there is a fail.
echo "------------------------------------"
echo ""
echo "Testing Packet sending 1 2 3..."
echo ""
echo "fwd_pkt1=Ether() / IP(dst='10.1.0.1') / TCP(sport=5793, dport=80); sendp(fwd_pkt1, iface='veth2')" | sudo scapy 2> err.log
lc=`wc -l err.log | cut -f 1 -d ' '`
#If a packet is sent successfully, a Pass message is displayed, if unsuccessfull, a Fail message is returned
#Also a temporary err.log file is created against which the Pass/Fail test is done.(Remember, this checks if the command is entered correctly)
#The 'lc' variable created helps in the check. Follow the commands, Should be pretty simple to understand
if [ $lc -gt 8 ]; then echo "Packet Send: FAILED"; else echo "Packet Send: PASSED"; fi
rm -r err.log


echo "drop_pkt1=Ether() / IP(dst='10.1.0.34') / TCP(sport=5793, dport=80); sendp(drop_pkt1, iface'veth2')" | sudo scapy 2> err.log
lc=`wc -l err.log | cut -f 1 -d ' '`
if [ $lc -gt 8 ]; then echo "Packet Send: FAILED"; else echo "Packet Send: PASSED"; fi
rm -r err.log


echo "fwd_pkt2=Ether() / IP(dst='10.1.0.1') / TCP(sport=5793, dport=80) / Raw('The quick brown fox jumped over the lazy dog.');sendp(fwd_pkt2, iface='veth2')" | sudo scapy 2> err.log
lc=`wc -l err.log | cut -f 1 -d ' '`
if [ $lc -gt 8 ]; then echo "Packet Send: FAILED"; else echo "Packet Send: PASSED"; fi
rm -r err.log

echo ""
echo ""
echo "*****************************"
echo "Script run successfully, All systems go!!!"
echo ""
echo ""
