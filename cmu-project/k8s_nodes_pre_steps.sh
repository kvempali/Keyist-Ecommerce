#!/bin/bash
chmod 400 private-key.pem
#ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "13.202.38.216"
#ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "13.202.8.68"
#ssh-keygen -f "/home/ubuntu/.ssh/known_hosts" -R "15.206.54.35"
#ssh-keyscan -H 13.202.38.216 >> ~/.ssh/known_hosts
#ssh-keyscan -H 13.202.8.68 >> ~/.ssh/known_hosts
#ssh-keyscan -H 15.206.54.35 >> ~/.ssh/known_hosts
rm -rf /home/ubuntu/.ssh/known_hosts
#ssh-keyscan -H 13.202.38.216 13.202.8.68 15.206.54.35 >> ~/.ssh/known_hosts
ssh-keyscan -H 13.202.38.216 >> ~/.ssh/known_hosts && ssh-keyscan -H 13.202.8.68 >> ~/.ssh/known_hosts && ssh-keyscan -H 15.206.54.35 >> ~/.ssh/known_hosts
