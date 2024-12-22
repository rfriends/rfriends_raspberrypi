raspberrypi用のrfriends3のインストール方法です。  
現在は、新規イメージのみを想定しています。  
  
1. 純正のimagerを使用してmicroSDを作成する。 
2. microSDをraspberrypiにセットし起動する。  
   領域拡張が完了するのを待つ。  
3. sshでraspberrypiにアクセスする。  
4. セットアップシェルを実行する。  
   cd  ~/  
   sudo apt install git  
   git clone https://github.com/rfriends/rfriends_raspberrypi.git  
   cd rfriends_raspberrypi  
   sh rfriends3_raspberrypi.sh  
5. raspberrypiを再起動する。  
   sudo reboot  
6. Webブラウザを使用してrfriendsにアクセスする。  
   http://xxx.xxx.xxx.xxx:8000
   
rfriends3イメージからのインストール簡易版は以下を参照ください。  
https://github.com/rfriends/rfriends_raspberrypi/wiki
