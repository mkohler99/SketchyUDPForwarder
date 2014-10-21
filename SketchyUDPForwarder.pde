import hypermedia.net.*;
import processing.net.*;
import controlP5.*;

Client c;
ControlP5 cp5;
int start_time;
Textlabel header;
Textlabel dot1;
Textlabel dot2;
Textlabel dot3;
Textlabel controllabel;
Textlabel netlabel;
Textlabel UDPlabel;
UDP udp;
String[] data;
PImage con;
PImage uncon;
float versionNum = 1.3;
int pannyDelay = 200;

void setup() {
  size(450,400);
  cp5 = new ControlP5(this);
  con = loadImage("connect.png");
  uncon = loadImage("wait.png"); 
  data = loadStrings("settings.txt");
  setupGUI();
  startServer();
  initialConnect();
}

void draw() {
  background(92);

}



//////////////////FUNCTIONS FOR CONTROL P5 SETUP //////////////////////////////////////////
void setupGUI() {
   //Sets up the User Interface
   start_time=millis();
   header = cp5.addTextlabel("label")
                    .setText("PANASONIC\n UDP Message Forwarder")
                    .setPosition(5,5)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-20.vlw"))
                    ;               
    controllabel = cp5.addTextlabel("controllabel")
                    .setText("Commands Sent To Device")
                    .setPosition(20,100)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-12.vlw"))
                    ;                 
    netlabel = cp5.addTextlabel("netlabel")
                    .setText("Remote Device Settings")
                    .setPosition(20,45)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-12.vlw"))
                    ;
    UDPlabel = cp5.addTextlabel("UDPlabel")
                    .setText("I'm Listening on UDP 6000 for MESSAGE1 MESSAGE2 etc.\nYou must send a newline after each message.\nI will send the command listed which you type in with a carriage return and\na newline\n\n\n\n(C)  2014 Michael Kohler"+"    Version "+str(versionNum))
                    .setPosition(20,300)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-12.vlw"))
                    ;
  int controlXPos = 50;
  int controlYPos = 120;
  // Message Field 1
  cp5.addTextfield("Message1", controlXPos+0, controlYPos,90,20);
  Textfield Msg1 = ((Textfield)cp5.getController("Message1"));
  Msg1.setValue(data[5]);
  cp5.addButton("send1")
     .setValue(0)
     .setPosition(controlXPos+100,controlYPos)
     .setSize(40,20)
     .activateBy(ControlP5.PRESSED);
     ;
     controlYPos += 40;  
     cp5.addTextfield("Message2", controlXPos+0, controlYPos,90,20);
  Textfield Msg2 = ((Textfield)cp5.getController("Message2"));
  Msg2.setValue(data[6]);
  cp5.addButton("send2")
     .setValue(0)
     .setPosition(controlXPos+100,controlYPos)
     .setSize(40,20)
     .activateBy(ControlP5.PRESSED);
     ; 
     controlYPos += 40; 
     cp5.addTextfield("Message3", controlXPos+0, controlYPos,90,20);
  Textfield Msg3 = ((Textfield)cp5.getController("Message3"));
  Msg3.setValue(data[7]);
  cp5.addButton("send3")
     .setValue(0)
     .setPosition(controlXPos+100,controlYPos)
     .setSize(40,20)
     .activateBy(ControlP5.PRESSED);
     ;
     controlYPos += 40;
     cp5.addTextfield("Message4", controlXPos+0, controlYPos,90,20);
  Textfield Msg4 = ((Textfield)cp5.getController("Message4"));
  Msg4.setValue(data[8]);
  cp5.addButton("send4")
     .setValue(0)
     .setPosition(controlXPos+100,controlYPos)
     .setSize(40,20)
     .activateBy(ControlP5.PRESSED);
     ;
  // create the IP Chooser
  int ipFieldYPos = 60;
  int ipFieldXPos = 50;
  cp5.addTextfield("Octet 1", ipFieldXPos+0, ipFieldYPos, 30, 20);
  cp5.addTextfield("Octet 2", ipFieldXPos+40, ipFieldYPos, 30, 20);
  cp5.addTextfield("Octet 3", ipFieldXPos+80, ipFieldYPos, 30, 20);
  cp5.addTextfield("Octet 4", ipFieldXPos+120, ipFieldYPos, 30, 20);
  cp5.addTextfield("Port", ipFieldXPos+160, ipFieldYPos, 90, 20);
  Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  ip1.setValue(data[0]);
  ip2.setValue(data[1]);
  ip3.setValue(data[2]);
  ip4.setValue(data[3]);
  ip1.setLabel("IP Address");
  ip2.setLabel("");
  ip3.setLabel("");
  ip4.setLabel("");
  port.setValue(data[4]);
  cp5.addButton("Connect")
     .setValue(0)
     .setPosition(ipFieldXPos+260,ipFieldYPos)
     .setSize(45,20)
     .activateBy(ControlP5.PRESSED);
     ;
  cp5.addButton("Disconnect")
     .setValue(0)
     .setPosition(ipFieldXPos+315,ipFieldYPos)
     .setSize(55,20)
     .activateBy(ControlP5.PRESSED);
     ;    
  cp5.addButton("Save")
     .setValue(0)
     .setPosition(390,375)
     .setSize(55,20)
     .activateBy(ControlP5.PRESSED);
     ;
     //Pretty Labels for IP Stuff
       dot1 = cp5.addTextlabel("dot1")
                    .setText(".")
                    .setPosition(78,60)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-20.vlw"))
                    ;
      dot2 = cp5.addTextlabel("dot2")
                    .setText(".")
                    .setPosition(119,60)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-20.vlw"))
                    ;
      dot2 = cp5.addTextlabel("dot3")
                    .setText(".")
                    .setPosition(159,60)
                    .setColorValue(0xffffffff)
                    .setFont(loadFont("Prototype-20.vlw"))
                    ;
}


///////////////////CP5 Connection Event Handlers//////////////////////////////////
public void Connect(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
  initialConnect();
}

void initialConnect() {
  Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  String theIP = ip1.getText()+'.'+ip2.getText()+'.'+ip3.getText()+'.'+ip4.getText();
  int thePort = int(port.getText());
  println("Attempting to Connect: "+theIP+ " Port: "+thePort);
  connectToDevice(theIP,thePort);
  c.stop();
}

public void Disconnect(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
  disconnectFromDevice();
}

public void Save(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
  saveSettings();
}

//BUTTONS FOR TEST SENDING COMMANDS

public void send1(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
    sendMessage1(); 
}
public void send2(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
    sendMessage2(); 
}
public void send3(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
    sendMessage3(); 
}
public void send4(int theValue) {
  if(millis()-start_time<1000){return;} //Trap to prevent CP5 from running the control at launch
    sendMessage4(); 
}

////////////////////PROCEDURES FOR COMMUNICATING WITH THE DEVICE////////////////////
void connectToDevice(String theIP, int thePort) {
  c = new Client(this, theIP, thePort);
  if(c.active()) {
  } else {
    println("Unable to connect to remote device!");
  }
}

void disconnectFromDevice() {
  println("Closing Connection");
  c.stop();
}

// THESE FUNCTIONS SEND THE MESSAGES IF YOU ARE SAFELY CONNECTED, IF NOT CONNECTED IT WILL IGNORE THEM
void sendMessage1() {
if(c.active()){
  c.write("%1AVMT 31"+'\r');
} else {
    println("Sending Message 1!");
    Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  String theIP = ip1.getText()+'.'+ip2.getText()+'.'+ip3.getText()+'.'+ip4.getText();
  int thePort = int(port.getText());
  println("Attempting to Connect: "+theIP+ " Port: "+thePort);
  connectToDevice(theIP,thePort);
    String msg = cp5.get(Textfield.class,"Message1").getText();
    delay(pannyDelay);
    c.write(msg+'\r');
}
    delay(pannyDelay);
    println("Closing Connection");
    c.stop();

}

void sendMessage2() {
if(c.active()){
  c.write("%1AVMT 30"+'\r');
} else {
    println("Sending Message 2!");
    Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  String theIP = ip1.getText()+'.'+ip2.getText()+'.'+ip3.getText()+'.'+ip4.getText();
  int thePort = int(port.getText());
  println("Attempting to Connect: "+theIP+ " Port: "+thePort);
  connectToDevice(theIP,thePort);
    String msg = cp5.get(Textfield.class,"Message2").getText();
    delay(pannyDelay);
    c.write(msg+'\r');
}
    delay(pannyDelay);
    println("Closing Connection");
    c.stop();

 
}

void sendMessage3() {
  if(c.active()){
  c.write("%1AVMT 30"+'\r');
} else {
    println("Sending Message 3!");
    Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  String theIP = ip1.getText()+'.'+ip2.getText()+'.'+ip3.getText()+'.'+ip4.getText();
  int thePort = int(port.getText());
  println("Attempting to Connect: "+theIP+ " Port: "+thePort);
  connectToDevice(theIP,thePort);
    String msg = cp5.get(Textfield.class,"Message3").getText();
    delay(pannyDelay);
    c.write(msg+'\r');
}
    delay(pannyDelay);
    println("Closing Connection");
    c.stop();

}

void sendMessage4() {
  if(c.active()){
  c.write("%1AVMT 30"+'\r');
} else {
    println("Sending Message 4!");
    Textfield ip1 = ((Textfield)cp5.getController("Octet 1"));
  Textfield ip2 = ((Textfield)cp5.getController("Octet 2"));
  Textfield ip3 = ((Textfield)cp5.getController("Octet 3"));
  Textfield ip4 = ((Textfield)cp5.getController("Octet 4"));
  Textfield port = ((Textfield)cp5.getController("Port"));
  String theIP = ip1.getText()+'.'+ip2.getText()+'.'+ip3.getText()+'.'+ip4.getText();
  int thePort = int(port.getText());
  println("Attempting to Connect: "+theIP+ " Port: "+thePort);
  connectToDevice(theIP,thePort);
    String msg = cp5.get(Textfield.class,"Message4").getText();
    delay(pannyDelay);
    c.write(msg+'\r');
}
    delay(pannyDelay);
    println("Closing Connection");
    c.stop();

}

//////////////////////PERSISTANCE SETTINGS/////////////////////////////////////////

void saveSettings() {
  String[] data = new String[9];
  data[0] = cp5.get(Textfield.class,"Octet 1").getText();
  data[1] = cp5.get(Textfield.class,"Octet 2").getText();
  data[2] = cp5.get(Textfield.class,"Octet 3").getText();
  data[3] = cp5.get(Textfield.class,"Octet 4").getText();
  data[4] = cp5.get(Textfield.class,"Port").getText();
  data[5] = cp5.get(Textfield.class,"Message1").getText();
  data[6] = cp5.get(Textfield.class,"Message2").getText();
  data[7] = cp5.get(Textfield.class,"Message3").getText();
  data[8] = cp5.get(Textfield.class,"Message4").getText();
  saveStrings(dataPath("settings.txt"), data); 
}
  


/////////////////// UDP MESSAGE CONTROL/////////////////////////////////////////////
 void startServer() {
   udp = new UDP( this, 6000);
   udp.listen(true);
 }

 //This callback handler deals with intercepting the 4 messages and forwarding the proper message
 void receive( byte[] data, String ip, int port ) { 
  
  data = subset(data, 0, data.length);
  String message = new String( data ); 
  if(message.equals("MESSAGE1\n")){
    println("This is Message 1");
    sendMessage1();  
  } else if(message.equals("MESSAGE2\n")){
    println("This is Message 2");
    sendMessage2();
  } else if(message.equals("MESSAGE3\n")){
    println("This is Message 3");
    sendMessage3();
  } else if(message.equals("MESSAGE4\n")){
    println("This is Message 4");
    sendMessage4();
  } else {
    println("I dont understand");
  }
}
  
  
