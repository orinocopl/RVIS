cd /home/user/nuandsdr/U/
(sleep 7 && echo -e ":P\n" > /dev/ttyACM0) &
(sleep 8 && java -Djna.library.path=/home/user/nuandsdr/U -cp .:jna-5.4.0.jar:jna-platform-5.4.0.jar:ReaderAPI20240822.jar:RXTXcomm.jar com.rscja.deviceapi.RFIDFixedReaderUR4) &


