raspberrypi用のrfriends3のインストール方法です。  
現在は、新規イメージのみを想定しています。  

Bullseye  
![bbulls](https://github.com/user-attachments/assets/b70bfbd6-53d4-4ff8-9e96-c73969b3fde8)
  
Bookworm  
![book](https://github.com/user-attachments/assets/8fe74637-4cb6-44ca-863d-e07c685ab105)
  
  
1. 純正のimagerを使用してmicroSDを作成する。   
2. microSDをraspberrypiにセットし起動する。  
   領域拡張が完了するのを待つ。  
3. sshでraspberrypiにアクセスする。  
4. セットアップシェルを実行する。  
   cd  ~/  
   sudo apt-get update && sudo apt-get upgrade -y  
   rm -rf rfriends_raspberrypi  
   sudo apt install git -y  
   git clone https://github.com/rfriends/rfriends_raspberrypi.git  
   cd rfriends_raspberrypi  
   sh rfriends3_raspberrypi.sh
6. raspberrypiを再起動する。  
   sudo reboot  
7. Webブラウザを使用してrfriendsにアクセスする。  
   http://xxx.xxx.xxx.xxx:8000
   
rfriends3イメージからのインストール簡易版は以下を参照ください。  
https://github.com/rfriends/rfriends_raspberrypi/wiki  　　
