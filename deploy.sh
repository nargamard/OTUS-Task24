# /bin/bash

## Убираем всё из known_hosts
echo "" > ~/.ssh/known_hosts 

#Так как виртуалок много, а памяти всего 4Гб, придётся задане сделать на домашнем сервере, там 64Гб ОЗУ
#Скопируем в nfs шару сервера файлы задания, запустим создание ВМ vagrant и плейбук
rsync -r . /home/user/shared_on_srv/OTUS-Task24/
ssh andrej@192.168.20.30 "sudo chmod -R 777 /mnt/STORAGE/Shared/OTUS-Task24/"
echo "Создаём виртуальные машины vagrant"
ssh andrej@192.168.20.30 "cd /mnt/STORAGE/Shared/OTUS-Task24/vagrant/ && vagrant up"

echo "Подождём пару минут..."
sleep 120
echo "Сделаем снапшоты со всех vagrant-машин"
echo "Подождём ещё минуту..."
sleep 60
ssh andrej@192.168.20.30 "cd /mnt/STORAGE/Shared/OTUS-Task24/vagrant/ && vagrant snapshot save inetRouter 1  --force && vagrant snapshot save centralRouter 2  --force && vagrant snapshot save office1Router 3 --force && vagrant snapshot save testClient1 4 --force && vagrant snapshot save testClient2 5 --force && vagrant snapshot save testServer1 6 --force && vagrant snapshot save testServer2  7 --force"

echo "Настраиваем сервер и клиент NFS"
#cd ..
ssh andrej@192.168.20.30 "cd /mnt/STORAGE/Shared/OTUS-Task24/ && ansible-playbook ansible/playbooks/deploy_network.yaml -i ansible/inventory/hosts --ssh-common-args='-o StrictHostKeyChecking=no' -b"
rsync -r /home/user/shared_on_srv/OTUS-Task24/ .

mv ansible/logfile_test_client1/testClient1/tmp/logfile_test_client1 .
mv ansible/logfile_test_server1/testServer1/tmp/logfile_test_server1 .
mv ansible/logfile_test_client2/testClient2/tmp/logfile_test_client2 .
mv ansible/logfile_test_server2/testServer2/tmp/logfile_test_server2 .
mv ansible/logfile_test_inetRouter/inetRouter/tmp/logfile_test_inetRouter .
rm -rf ansible/logfile_test_client1
rm -rf ansible/logfile_test_server1
rm -rf ansible/logfile_test_client2
rm -rf ansible/logfile_test_server2
rm -rf ansible/logfile_test_inetRouter

mv /tmp/script.log .

echo "Файлы с логами находятся рядом со скриптом"