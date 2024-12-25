現在、メンテナンス中  
  
  
[注意] bookwormでは正常動作しません。bullseyeを使用してください。   
  
raspberrypi用のrfriends3のインストール方法です。  
現在は、新規イメージのみを想定しています。  
  
1. 純正のimagerを使用してmicroSDを作成する。(bullseye 32bits nodesktop)   
2. microSDをraspberrypiにセットし起動する。  
   領域拡張が完了するのを待つ。  
3. sshでraspberrypiにアクセスする。  
4. セットアップシェルを実行する。  
   cd  ~/  
   sudo apt update && sudo apt upgrade -y  
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
