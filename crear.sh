#-----FIREWALLLL---------
#EXT ENS192 11.1.21.254 11.0.0.0/16
#DMZ-E ENS256 192.168.21.193 192.168.21.192/27  
#LAN  ENS224  192.168.21.161  192.168.21.160/27
#DMZ ENS161  192.168.21.225  192.168.21.224/27


#------LAN-----------
#UBUNTU_ANDONI  192.1168.21.172
#DEBIAN_CARLOS   192.168.21.171
#DEBIAN_AIMAR    192.168.21.170
#WINDOWS11_MIKEL 192.168.169


#-----DMZE--------------
#DEBIAN_WEB  192.168.21.194
#DNS1   

#-----DMZ----------------
#DNS1  192.168.21.226
#DNS2  192.168.21.227
#DOCKER_DB 192.168.21.229
#GRAFANA 192.168.21.230





#---------------SENTENCIAS DROP-----------------------------------------------------------------------------
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP
#-------------SENTENCIAS DE VUELTA DE PETICIONES ESTABLECIDAS-----------------------------------------------
iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A OUTPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

#----------------FIREWALL--------------------------------------------------------------------------------------
# Para conectarnos mediante SSH desde la FUERA al Firewal
iptables -A INPUT -d 11.1.21.254 -i ens224 -2 -p tcp --dport 22 -j ACCEPT

# PARA PODER HACER PING DESDE CUALQUIER LA MÁQUINA AL FW
iptables -A INPUT -o  ens161 -j -p icmp --icmp-type echo-request -j ACCEPT

#------------------DOCKER_DB------------------------------------------------------------------------------------
#Para aceptar la conexión ssh de la subred de la LAN
iptables -A FORWARD -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.229 -p tcp --dport ssh -j ACCEPT

#Para conectarnos a la base desde la subred de la LAN
iptables -A FORWARD -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.229 -p tcp --dport 33060 -j ACCEPT

#Para conectarnos a percona
iptables -A FORWARD -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.229 -p tcp --dport 3000 -j ACCEPT

#Para permitir DNS
iptables -A FORWARD -s 192.168.21.229 -p udp --dport 53 -d 8.8.8.8 -j ACCEPT



#----------------------DEBIAN_WEB---------------------------------------------------------------------------
#Para aceptar la conexión ssh de la subred de la LAN
iptables -A FORWARD  -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.195 -p tcp --dport ssh -j ACCEPT
#Permitir accesos alas webs por http
iptables -A FORWARD  -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.195 -p tcp --dport 80 -j ACCEPT
#Permitir accesos alas webs por https
iptables -A FORWARD  -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.195 -p tcp --dport 443 -j ACCEPT

#iptables -A FORWARD  -i ens224 -s 192.168.21.160/27 -o ens161 -d 192.168.21.195  -j REJECT
#-------------------DNS1_DMZ------------------------
#Permitir SSH desde lan
iptables -A FORWARD  -i ens161 -s 192.168.21.160/27 -o ens224 -d 192.168.21.226 -p tcp --dport ssh -j ACCEPT

iptables -A FORWARD  -i ens161 -s 192.168.21.160/27 -o ens224 -d 192.168.21.226 -p tcp --dport 53 -j ACCEPT

iptables -A FORWARD  -i ens161 -s 192.168.21.160/27 -o ens224 -d 192.168.21.226 -p udp --dport 53 -j ACCEPT

#iptables -A FORWARD  -i ens161 -s 192.168.21.160/27 -o ens224 -d 192.168.21.226  -j REJECT
#-------------------DNS2_DMZ--------------------------------
iptables -A FORWARD -d 192.168.21.227 -p tcp --dport ssh -j ACCEPT
iptables -A FORWARD -d 192.168.21.227 -p tcp --dport 53 -j ACCEPT
iptables -A FORWARD -d 192.168.21.227 -p udp --dport 53 -j ACCEPT
#iptables -A FORWARD -d 192.168.21.227  -j REJECT


#-------------------ESCRITORIO REMOTO--------------------------------
iptables -A FORWARD -s 10.60.5.0 -d 192.168.21.169 -p tcp,udp --dport 3389 -j ACCEPT
