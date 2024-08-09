#!/bin/bash
clear && clear
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/Africa/Algiers /etc/localtime &>/dev/null

apt install net-tools -y &>/dev/null
myip=$(ifconfig | grep -Eo 'inet (addr:)?([0-9]*\.){3}[0-9]*' | grep -Eo '([0-9]*\.){3}[0-9]*' | grep -v '127.0.0' | head -n1)
myint=$(ifconfig | grep -B1 "inet addr:$myip" | head -n1 | awk '{print $1}')
rm -rf /etc/localtime &>/dev/null
ln -s /usr/share/zoneinfo/Africa/Algiers /etc/localtime &>/dev/null
rm -rf /usr/local/lib/systemubu1 &>/dev/null
rm -rf /etc/versin_script &>/dev/null
v1=$(curl -sSL "https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/Version")
echo "$v1" >/etc/versin_script
[[ ! -e /etc/versin_script ]] && echo 1 >/etc/versin_script
v22=$(cat /etc/versin_script)
vesaoSCT="\033[1;31m [ \033[1;32m($v22)\033[1;97m\033[1;31m ]"
### COLORS AND BAR
msg() {
   BRAN='\033[1;37m' && RED='\e[31m' && GREEN='\e[32m' && YELLOW='\e[33m'
  BLUE='\e[34m' && MAGENTA='\e[35m' && MAG='\033[1;36m' && BLACK='\e[1m' && SEMCOR='\e[0m'
  case $1 in
  -ne) cor="${RED}${BLACK}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -ama) cor="${YELLOW}${BLACK}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verm) cor="${YELLOW}${BLACK}[!] ${RED}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -azu) cor="${MAG}${BLACK}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -verd) cor="${GREEN}${BLACK}" && echo -e "${cor}${2}${SEMCOR}" ;;
  -bra) cor="${RED}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -nazu) cor="${COLOR[6]}${BLACK}" && echo -ne "${cor}${2}${SEMCOR}" ;;
  -gri) cor="\e[5m\033[1;100m" && echo -ne "${cor}${2}${SEMCOR}" ;;
  "-bar2" | "-bar") cor="${RED}———————————————————————————————" && echo -e "${SEMCOR}${cor}${SEMCOR}" ;;
  esac
}
fun_bar() {
  comando="$1"
  _=$(
    $comando >/dev/null 2>&1
  ) &
  >/dev/null
  pid=$!
  while [[ -d /proc/$pid ]]; do
    echo -ne " \033[1;33m["
    for ((i = 0; i < 20; i++)); do
      echo -ne "\033[1;31m##"
      sleep 0.5
    done
    echo -ne "\033[1;33m]"
    sleep 1s
    echo
    tput cuu1
    tput dl1
  done
  echo -e " \033[1;33m[\033[1;31m##############################\033[1;33m] - \033[1;32m100%\033[0m"
  sleep 1s
}

print_center() {
  if [[ -z $2 ]]; then
    text="$1"
  else
    col="$1"
    text="$2"
  fi

  while read line; do
    unset space
    x=$(((54 - ${#line}) / 2))
    for ((i = 0; i < $x; i++)); do
      space+=' '
    done
    space+="$line"
    if [[ -z $2 ]]; then
      msg -azu "$space"
    else
      msg "$col" "$space"
    fi
  done <<<$(echo -e "$text")
}

title() {
  clear
  msg -bar
  if [[ -z $2 ]]; then
    print_center -azu "$1"
  else
    print_center "$1" "$2"
  fi
  msg -bar
}



stop_install() {
  title "INSTALLATION CANCELED"
  exit
}

time_reboot() {
  print_center -ama "RESTARTING VPS IN $1 SECONDS"
  REBOOT_TIMEOUT="$1"

  while [ $REBOOT_TIMEOUT -gt 0 ]; do
    print_center -ne "-$REBOOT_TIMEOUT-\r"
    sleep 1
    : $((REBOOT_TIMEOUT--))
  done
  reboot
}

os_system() {
  system=$(cat -n /etc/issue | grep 1 | cut -d ' ' -f6,7,8 | sed 's/1//' | sed 's/      //')
  distro=$(echo "$system" | awk '{print $1}')

  case $distro in
  Debian) vercion=$(echo $system | awk '{print $3}' | cut -d '.' -f1) ;;
  Ubuntu) vercion=$(echo $system | awk '{print $2}' | cut -d '.' -f1,2) ;;
  esac
}

repo() {
  link="https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/Source-List/20.04.list"
  case $1 in
  8 | 9 | 10 | 11 | 16.04 | 18.04 | 20.04 | 20.10 | 21.04 | 21.10 | 22.04) wget -O /etc/apt/sources.list ${link} &>/dev/null ;;
  esac
}

dependencias() {
  soft="sudo bsdmainutils zip unzip ufw curl python python3 python3-pip  screen cron iptables lsof pv nano at mlocate gawk grep bc jq  nodejs socat netcat netcat-traditional net-tools cowsay figlet lolcat"

  for i in $soft; do
    leng="${#i}"
    puntos=$((21 - $leng))
    pts="."
    for ((a = 0; a < $puntos; a++)); do
      pts+="."
    done
    msg -nazu "    installing $i$(msg -ama "$pts")"
    if apt install $i -y &>/dev/null; then
      msg -verd " INSTALLED"
    else
      msg -verm2 " ERROR"
      sleep 2
      tput cuu1 && tput dl1
      print_center -ama "applying fix to $i"
      dpkg --configure -a &>/dev/null
      sleep 2
      tput cuu1 && tput dl1

      msg -nazu "    installing $i$(msg -ama "$pts")"
      if apt install $i -y &>/dev/null; then
        msg -verd " INSTALLED"
      else
        msg -verm2 " ERROR"
      fi
    fi
  done
}

post_reboot() {
  echo 'wget -O /root/install.sh "https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/installer/install-without-key.sh"; clear; sleep 2; chmod +x /root/install.sh; /root/install.sh --continue' >>/root/.bashrc
  title -verd "COMPLETED SYSTEM UPGRADE"
  print_center -ama "The installation will continue\nafter rebooting!!!"
  msg -bar
}

install_start() {
  msg -bar

  echo -e "\e[1;97m           \e[5m\033[1;100m   SYSTEM UPDATE   \033[1;37m"
  msg -bar
  print_center -ama "System packages are updating.\n It may take a while and ask for some confirmations.\n"
  msg -bar3
  msg -ne "\n Do you wish to continue? [Y/N]: "
  read opcion
  [[ "$opcion" != @(y|Y) ]] && stop_install
  clear && clear
  msg -bar
  echo -e "\e[1;97m           \e[5m\033[1;100m   SYSTEM UPDATE   \033[1;37m"
  msg -bar
  os_system
  apt update -y
}

install_continue() {
  os_system
  msg -bar
  echo -e "      \e[5m\033[1;100m   COMPLETING PACKAGES FOR THE SCRIPT   \033[1;37m"
  msg -bar
  print_center -ama "$distro $vercion"
  print_center -verd "INSTALLING DEPENDENCIES"
  msg -bar3
  dependencias
  msg -bar3
  print_center -azu "Removing obsolete packages"
  apt autoremove -y &>/dev/null
  sleep 2
  tput cuu1 && tput dl1
  msg -bar
  print_center -ama "If some of the dependencies fail!!!\nwhen finished, yto install\nthe same manually using the following command\napt install package_name"
  msg -bar
  read -t 60 -n 1 -rsp $'\033[1;39m       << Press enter to continue >>\n'
}

while :; do
  case $1 in
  -s | --start) install_start && post_reboot && time_reboot "15" ;;
  -c | --continue)
    #rm /root/install-without-key.sh &>/dev/null
    sed -i '/installer/d' /root/.bashrc
    install_continue
    break
    ;;
  # -u | --update)
  #   install_start
  #   install_continue
  #   break
  # ;;
  *) exit ;;
  esac
done

clear && clear
msg -bar2
echo -e " \e[5m\033[1;100m ===>> ►► 🐲 VPS-AR - SCRIPT  🐲 ◄◄ <<===   \033[1;37m"
msg -bar2
print_center -ama "AVAILABLE SCRIPT LIST"
msg -bar
#-BASH SOPORTE ONLINE
wget https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/LINKS-LIBRARIES/SPR.sh -O /usr/bin/SPR >/dev/null 2>&1
chmod +x /usr/bin/SPR


#VPS-AR 1.1 OFFICIAL
install_official() {
  clear && clear
  msg -bar
  echo -ne "\033[1;97m Type your slogan: \033[1;32m" && read slogan
  tput cuu1 && tput dl1
  echo -e "$slogan"
  msg -bar
  clear && clear
  mkdir /etc/VPS-AR >/dev/null 2>&1
  cd /etc
  wget https://github.com/vpsvip7/VPS-AR/raw/main/VPS-AR.tar.xz >/dev/null 2>&1
  tar -xf VPS-AR.tar.xz >/dev/null 2>&1
  chmod +x VPS-AR.tar.xz >/dev/null 2>&1
  rm -rf VPS-AR.tar.xz
  cd
  chmod -R 755 /etc/VPS-AR
  rm -rf /etc/VPS-AR/MEUIPvps
  echo "/etc/VPS-AR/menu" >/usr/bin/menu && chmod +x /usr/bin/menu
  echo "/etc/VPS-AR/menu" >/usr/bin/VPSAR && chmod +x /usr/bin/VPSAR
  wget https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/LINKS-LIBRARIES/monitor.sh -P /bin/
  echo "$slogan" >/etc/VPS-AR/message.txt
  [[ ! -d /usr/local/lib ]] && mkdir /usr/local/lib
  [[ ! -d /usr/local/lib/ubuntn ]] && mkdir /usr/local/lib/ubuntn
  [[ ! -d /usr/local/lib/ubuntn/apache ]] && mkdir /usr/local/lib/ubuntn/apache
  [[ ! -d /usr/local/lib/ubuntn/apache/ver ]] && mkdir /usr/local/lib/ubuntn/apache/ver
  [[ ! -d /usr/share ]] && mkdir /usr/share
  [[ ! -d /usr/share/mediaptre ]] && mkdir /usr/share/mediaptre
  [[ ! -d /usr/share/mediaptre/local ]] && mkdir /usr/share/mediaptre/local
  [[ ! -d /usr/share/mediaptre/local/log ]] && mkdir /usr/share/mediaptre/local/log
  [[ ! -d /usr/share/mediaptre/local/log/lognull ]] && mkdir /usr/share/mediaptre/local/log/lognull
  [[ ! -d /etc/VPS-AR/B-VPS-ARuser ]] && mkdir /etc/VPS-AR/B-VPS-AGNuser
  [[ ! -d /usr/local/protec ]] && mkdir /usr/local/protec
  [[ ! -d /usr/local/protec/rip ]] && mkdir /usr/local/protec/rip
  [[ ! -d /etc/protecbin ]] && mkdir /etc/protecbin
  cd
  [[ ! -d /etc/VPS-AR/v2ray ]] && mkdir /etc/VPS-AR/v2ray
  [[ ! -d /etc/VPS-AR/Slow ]] && mkdir /etc/VPS-AR/Slow
  [[ ! -d /etc/VPS-AR/Slow/install ]] && mkdir /etc/VPS-AR/Slow/install
  [[ ! -d /etc/VPS-AR/Slow/Key ]] && mkdir /etc/VPS-AR/Slow/Key
  touch /usr/share/lognull &>/dev/null
  wget -O /bin/resetsshdrop https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/LINKS-LIBRARIES/resetsshdrop &>/dev/null
  chmod +x /bin/resetsshdrop
  grep -v "^PasswordAuthentication" /etc/ssh/sshd_config >/tmp/passlogin && mv /tmp/passlogin /etc/ssh/sshd_config
  echo "PasswordAuthentication yes" >>/etc/ssh/sshd_config
  rm -rf /usr/local/lib/systemubu1 &>/dev/null
  rm -rf /etc/versin_script &>/dev/null
  v1=$(curl -sSL "https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/Version")
  echo "$v1" >/etc/versin_script
  wget -O /etc/versin_script_new https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/Version &>/dev/null
  echo '#!/bin/sh -e' >/etc/rc.local
  sudo chmod +x /etc/rc.local
  echo "sudo resetsshdrop" >>/etc/rc.local
  echo "sleep 2s" >>/etc/rc.local
  echo "exit 0" >>/etc/rc.local
  echo 'clear' >>.bashrc
  echo 'echo ""' >>.bashrc
  echo 'echo -e "\t\033[91m __      _______   _____              _____ _   _ " ' >>.bashrc
  echo 'echo -e "\t\033[91m \ \    / /  __ \ / ____|       /\      7777  " ' >>.bashrc
  echo 'echo -e "\t\033[91m  \ \  / /| |__) | (___ ______ /  \     7  777  " ' >>.bashrc
  echo 'echo -e "\t\033[91m   \ \/ / |  ___/ \___ \______/ /\ \    77777 " ' >>.bashrc
  echo 'echo -e "\t\033[91m    \  /  | |     ____) |    / ____ \   7  77 " ' >>.bashrc
  echo 'echo -e "\t\033[91m     \/   |_|    |_____/    /_/    \_\  7     77" ' >>.bashrc
  echo 'wget -O /etc/versin_script_new https://raw.githubusercontent.com/vpsvip7/VPS-AR/main/Version &>/dev/null' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'mess1="$(less /etc/VPS-AR/message.txt)" ' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[92mRESELLER : $mess1 "' >>.bashrc
  echo 'echo -e "\t\e[1;33mVERSION: \e[1;31m$(cat /etc/versin_script_new)"' >>.bashrc
  echo 'echo "" ' >>.bashrc
  echo 'echo -e "\t\033[97mTO DISPLAY BASH PANEL TYPE: sudo VPSAGN or menu "' >>.bashrc
  echo 'echo ""' >>.bashrc
  rm -rf /usr/bin/pytransform &>/dev/null
  rm -rf VPS-AR.sh
  rm -rf lista-arq
  service ssh restart &>/dev/null
  clear && clear
  msg -bar
  echo -e "\e[1;92m             >> INSTALLATION COMPLETED <<" && msg bar2
  echo -e "      MAIN COMMAND TO ENTER THE PANEL "
  echo -e "                      \033[1;41m  menu  \033[0;37m" && msg -bar2
}

#MENUS
/bin/cp /etc/skel/.bashrc ~/
/bin/cp /etc/skel/.bashrc /etc/bash.bashrc
echo -ne " \e[1;93m [\e[1;32m1\e[1;93m]\033[1;31m > \e[1;97m INSTALL 1.1 OFFICIAL \e[97m \n"
msg -bar
echo -ne "\033[1;97mEnter only the number according to your answer:\e[32m "
read opcao
case $opcao in
1)
  install_official
  ;;
esac
exit
