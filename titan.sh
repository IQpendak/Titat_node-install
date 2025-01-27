channel_logo() {
  echo -e '\033[0;31m'7
 echo -e '╔══╗╔═══╗╔═══╗╔═══╗╔╗─╔╗╔══╗─╔══╗╔╗╔══╗'
 echo -e '╚╗╔╝║╔═╗║║╔═╗║║╔══╝║╚═╝║║╔╗╚╗║╔╗║║║║╔═╝'
 echo -e '─║║─║║─║║║╚═╝║║╚══╗║╔╗─║║║╚╗║║╚╝║║╚╝║──'
 echo -e '─║║─║║╔╝║║╔══╝║╔══╝║║╚╗║║║─║║║╔╗║║╔╗║──'
 echo -e '╔╝╚╗║╚╝─║║║───║╚══╗║║─║║║╚═╝║║║║║║║║╚═╗'
 echo -e '╚══╝╚═══╝╚╝───╚═══╝╚╝─╚╝╚═══╝╚╝╚╝╚╝╚══╝'
  echo -e '\e[0m'
  echo -e "\n\nПідпишіться на наш канал  https://t.me/+99BzkAhA5qljZjcy"
}
download_node() {
  if [ -d "$HOME/.titanedge" ]; then
    echo "Папка .titanedge вже присутня. Видаліть ноду і встановіть її знову. Вихід..."
    return 0
  fi

  echo 'Починаю встановлення...'

  cd $HOME

  sudo apt update -y && sudo apt upgrade -y
  sudo apt-get install nano git gnupg lsb-release apt-transport-https jq screen ca-certificates curl -y

  if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    rm get-docker.sh
  else
    echo "Docker вже встановлений. Пропускаєм"
  fi

  if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | jq -r .tag_name)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
  else
    echo "Docker-Compose вже встановлений. Пропускаєм"
  fi

  echo 'Необхідні залежності було встановлено. Запустіть 2 пункт.'
}

launch_node() {
  container_id=$(docker ps -a --filter "ancestor=nezha123/titan-edge" --format "{{.ID}}")

  if [ -n "$container_id" ]; then
    echo "Знайдено контейнер: $container_id"
    docker stop $container_id
    docker rm $container_id
  fi

  while true; do
    echo -en "Введіть ваш HASH:${NC} "
    read HASH
    if [ ! -z "$HASH" ]; then
        break
    fi
    echo 'HASH не може бути пустим.'
  done

  docker run --network=host -d -v ~/.titanedge:/root/.titanedge nezha123/titan-edge
  sleep 10

  docker run --rm -it -v ~/.titanedge:/root/.titanedge nezha123/titan-edge bind --hash=$HASH https://api-test1.container1.titannet.io/api/v2/device/binding
  
  echo -e "Нода була запущена."
}

docker_logs() {
  docker logs $(docker ps -a --filter "ancestor=nezha123/titan-edge" --format "{{.ID}}")
}

restart_node() {
  docker restart $(docker ps -a --filter "ancestor=nezha123/titan-edge" --format "{{.ID}}")
  echo 'Нода була перезагружена.'
}

stop_node() {
  docker stop $(docker ps -a --filter "ancestor=nezha123/titan-edge" --format "{{.ID}}")
  echo 'Нода була зупинена.'
}

delete_node() {
  read -p 'Якщо ви впевнені, щоб видалити ноду, напишіть будь-який символ (CTRL+C щоб вийти): ' checkjust

  docker_id=$(docker ps -a --filter "ancestor=nezha123/titan-edge" --format "{{.ID}}")
  docker stop $docker_id
  docker rm $docker_id

  sudo rm -r $HOME/.titanedge

  echo 'Нода була видалена.'
}

exit_from_script() {
  exit 0
}

while true; do
    channel_logo
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. Встановити ноду"
    echo "2. Запустити ноду"
    echo "3. Провірити логи"
    echo "4. Перезагрузити ноду"
    echo "5. Зупинити ноду"
    echo "6. Видалити ноду"
    echo -e "7. Вийти изз скрипта\n"
    read -p "Виберіть пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        docker_logs
        ;;
      4)
        restart_node
        ;;
      5)
        stop_node
        ;;
      6)
        delete_node
        ;;
      7)
        exit_from_script
        ;;
      *)
        echo "Неправильний пункт. Будь-ласка, виберіть правильну цифру в меню."
        ;;
    esac
  done
