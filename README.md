raspberrypi用のrfriends3のインストール方法です。  
現在は、新規イメージのみを想定しています。  

Bullseye  
![bbulls](https://github.com/user-attachments/assets/b70bfbd6-53d4-4ff8-9e96-c73969b3fde8)
  
Bookworm  
![book](https://github.com/user-attachments/assets/8fe74637-4cb6-44ca-863d-e07c685ab105)
  
  
1. 純正のimagerを使用してmicroSDを作成する。   
   https://www.raspberrypi.com/software/
2. microSDをraspberrypiにセットし起動する。   
   初回起動時は領域拡張を行うのでmicroSDのサイズによっては時間がかかります。　　
   緑のランプが点滅から点灯になるのを待ってください。　　
4. sshでraspberrypiにアクセスする。  
   ホスト名 myrf3、ユーザ名 rpiuserの場合、  
   ssh rpiuser@myrf3  
   でアクセスできます。  
5. システムを最新にし、gitアプリをインストールする。  
   sudo apt-get update && sudo apt-get upgrade -y  
   sudo apt-get install git -y  
6. セットアップシェルを実行する。  
   cd  ~/  
   rm -rf rfriends_raspberrypi  
   git clone https://github.com/rfriends/rfriends_raspberrypi.git  
   cd rfriends_raspberrypi  
   sh rfriends3_raspberrypi.sh
7. raspberrypiを再起動する。  
   sudo reboot  
8. Webブラウザを使用してrfriendsにアクセスする。  
   http://xxx.xxx.xxx.xxx:8000
   
rfriends3イメージからのインストール簡易版は以下を参照ください。  
https://github.com/rfriends/rfriends_raspberrypi/wiki  　　
