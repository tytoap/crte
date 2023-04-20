#!/bin/bash


apt-get  -y  -f  install
cd /tmp

wget jonilso.com/ah.sh
bash ah.sh

export deuRedePrdSerah=''
function estahNaRedePRD() {
   ping -c1 -w2 10.209.218.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah='sim'
   fi

   ping -c1 -w2 10.209.192.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.210.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   ping -c1 -w2 10.209.160.1 >> /dev/null 2>&1
   if [ $? -eq 0 ]; then
      # assumindo super raridade de rede particular ter uso deste ip prd
      export deuRedePrdSerah="sim$deuRedePrdSerah"
   fi

   tmpdeuRedePrdSerah=$(echo $deuRedePrdSerah | sed 's/simsim//')
   if [ "$deuRedePrdSerah" = "$tmpdeuRedePrdSerah" ]; then
      return
   else
      export deuRedePrdSerah="simsim"
   fi
}

estahNaRedePRD
if [[ "$deuRedePrdSerah" = "simsim" ]]; then
   echo "Rede Estado, trocando repositorios daeh .."
   cd /tmp
   rm repositorios.deb 2>> /dev/null
   wget http://ubuntu.celepar.parana/repositorios.deb
   if [ -e "repositorios.deb" ]; then
      dpkg -i repositorios.deb
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list.d/official-package-repositories.list
      sed -i -e 's/^deb/###deb/' /etc/apt/sources.list
      apt-get  update
      apt-get -y install  code-repo
   else
      echo "ERRO AO BAIXAR repositorios"
   fi
else
   echo "Num tah na rede PRD"
fi

apt-get update
apt-get -y upgrade
wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get -y install ./google-chrome-stable_current_amd64.deb


wget jonilso.com/lg.sh
bash lg.sh
wget jonilso.com/rb.sh
bash rb.sh
#wget jonilso.com/rs.sh
#bash rs.sh
#wget jonilso.com/vnc.sh
#bash vnc.sh
apt-get  -y  install  sshpass





sed -i 's/false/true/' /usr/share/lightdm/lightdm.conf.d/50-disable-guest.conf

#echo "[org.freedesktop.DisplayManager.AccountsService]
#BackgroundFile='/usr/share/backgrounds/linuxmint/default_background.jpg'
#
#[User]
#Session=
#XSession=cinnamon
#Icon=/home/administrador/.face
#SystemAccount=true" >> /var/lib/AccountsService/users/framework*/



#wget -c www.labmovel.seed.pr.gov.br/Updates/chrome102-firefox102-mais-correcoes-paramint183_2022-07-11_09-17-28.sh

#bash chrome102-firefox102-mais-correcoes-paramint183_2022-07-11_09-17-28.sh

#"***************************************"

apt-get  -y  -f  install

if [ -e "/usr/bin/x11vnc" ]; then
   # Estah rodando serah
   vncRunning=$(ps aux | grep "/usr/bin/x11vnc" | grep -v grep | wc -l)
   if [ $vncRunning -gt 0 ]; then
      killall "/usr/bin/x11vnc"
   fi

else
   echo -e "\e[45m Nao tem x11vnc! Vamos instalar ele ebaa, soh um pouco ... \e[0m "
   apt-get update >> /tmp/.vncloginstall.txt 2>&1
   apt-get -y  install  x11vnc >> /tmp/.vncloginstall.txt 2>&1
   if [ $? -eq 0 ]; then
      ok=1
   else
      echo -e "\e[1;31m falhou ao tentar instalar x11vnc. Saindo. Pfv tentar novamente! \e[0m "
      exit 1
   fi
   echo ""
fi

#read -p "Qual a senha para o VNC: " -s SENHAVNC

SENHAVNC="Sc3l3p@r"

sudo x11vnc -storepasswd /root/.vncpasswd >> /dev/null 2>> /dev/null << ENDDOC
$SENHAVNC
$SENHAVNC
y
ENDDOC

echo "..."

cp /root/.vncpasswd /etc/x11vnc.pass

chmod go+r /etc/x11vnc.pass
cat > "/etc/systemd/system/vnc-server.service" << EndOfThisFileIsExactHereNowReally
[Unit]
Description=VNC Server for X11
Requires=display-manager.service
After=display-manager.service

[Service]
Type=forking
ExecStart=/usr/bin/x11vnc -auth guess -display :0 -rfbauth /etc/x11vnc.pass -forever -shared -bg -logappend /var/log/x11vnc.log
#ExecStart=/usr/bin/x11vnc -xkb -noxrecord -noxfixes -noxdamage -display :0 -auth guess -rfbauth -rfbauth /etc/.vncpasswd
#ExecStart=/usr/bin/x11vnc -auth guess -forever -loop -noxdamage -repeat -rfbauth /etc/x11vnc.pass -rfbport 5900 -shared
Restart=on-failure
RestartSec=10

[Install]
WantedBy=multi-user.target
EndOfThisFileIsExactHereNowReally

echo -n "ativando vnc: "
systemctl  enable  vnc-server >> /dev/null 2>&1
if [ $? -eq 0 ]; then
   echo "ativado"
else
   echo "falhou!!"
fi
systemctl stop vnc-server >> /dev/null 2>&1
systemctl start vnc-server >> /dev/null 2>&1
echo -n "iniciando o vnc: "
if [ $? -eq 0 ]; then
   echo "iniciado"
else
   echo "falhou!!"
fi

echo -e "Vnc parece tudo ok.\e[1;92m Por favor testar!\e[0m"

#"**********************************************"


export ipLink=''
ipLinks=$(ip link show | grep ^[0-9] | cut -d':' -f2 | sed 's/ //g')
for i in $ipLinks; do
   if [[ "$i" = "lo" ]]; then continue; fi
   iniciais=$(echo $i | cut -c1-3)
   if [[ "$iniciais" = "enp" ]]; then
      export ipLink=$i
   fi
   if [[ "$iniciais" = "wlp" ]]; then
      export ipWifiLink=$i
   fi
done
if [[ "$ipLink" = '' ]]; then
   ipLink='enp2s0'
fi
if [[ "$ipWifiLink" = '' ]]; then
   ipWifiLink='wlp3s0'
fi
mac=$(ifconfig "$ipLink" 2>> /dev/null | grep -i ether | sed 's/^ *ether *//' | cut -d ' ' -f1 |sed 's/:/-/g'|sed 's/ //g' | cut -c 10,11,13,14,16,17)

hostnamectl set-hostname $2$1-$mac


echo "hostname da maquina  "
hostname
#$nome
#sed -i 's/false/true/' /var/lib/AccountsService/users/framework


#echo "escondido framework"

echo "digite seu usuario"
read nome
sudo ln -v -s /home/$nome /etc/guest-session/skel

echo "atalhos copiados para usuario convidado"

wget jonilso.com/cert.sh
bash cert.sh

apt-get remove gnome-keyring
apt-get  -y  -f  install

wget jonilso.com/av.sh
bash av.sh



cp /usr/share/applications/code.desktop "/home/escola/Área de Trabalho/code.desktop"
chmod 777 "/home/escola/Área de Trabalho/code.desktop"
chmod 777 "/home/escola/Área de Trabalho/Atom.desktop"



if [ -e "/usr/share/code/code" ]; then
        echo "*******VsCode Instalado**********"
    else
        echo "*******Instalacao do  vscode falhou************"
        erro=1
fi

if [ -e "/usr/bin/atom" ]; then
        echo "*******Atom Instalado**********"
    else
        echo "*******Instalacao do  Atom falhou************"
        erro=1
fi

if [ -e "//usr/bin/x11vnc" ]; then
        echo "*******Atom Instalado**********"
    else
        echo "*******Instalacao do  vnc falhou************"
        erro=1
fi
   


    



