
/**Roundhouse Human Harp Visualisation
  *@author Alessia Milo
  *@project Human Harp Roundhouse LiveLab
  *1.The sketch takes Harp Player OSC messages routed from PD patch  
  *and transforms them into graphical information displayed in the model 
  *humanharp.org
  *https://github.com/Human-Harp/human-harp-sound
  *2.Instructions: Connect by wireless to Human Harp Channel
  *Open the PureData Human Harp patch and load the sound
  *Choose parameters in Pure Data to pair Players with sounds.
  *Run this sketch. 
  *Play the Harp Player. Check the interaction in the model and listen
  *Enable saving audio/video if you want to record the sound
  *Write Interaction Data in a text file by pressing p. 
  *
  */

import oscP5.*;
import netP5.*;

//import Minim library
  import ddf.minim.*;
  import ddf.minim.UGen;
  import ddf.minim.ugens.*;
//for displaying the sound's frequency
  import ddf.minim.analysis.*;
//import PeasyCam
  import peasy.test.*;
  import peasy.org.apache.commons.math.*;
  import peasy.*;
  import peasy.org.apache.commons.math.geometry.*;
  import java.util.Date;
//  import codeanticode.gsvideo.*;

//GSMovieMaker mm;
int fps=30;

PrintWriter output;
PeasyCam cam;
Minim minim;
String rd;


boolean HumanHarpON = true;
  int count;
  int spacing;
  float rightShift;
  float leftShift;
  PFont f;
   float spectrumScale = 10;
     float centerFrequency = 0;
     int asMidi;
     Frequency  currentFreq;

  int player=1;
  float xBasePoint=0;
  float yBasePoint=0;
  float xPlayer=0;
  float yPlayer=0;
  float phaseShift=0;
  float period = PI/200;

  int playerNumber=0;
  int numOfPlayers = 12;   //leave this with 12 to use coded players (ex: 101, 107, 110);
  Player[] players;
  int playerHighLighted = 0;
   String parameter;
   float value;
 int index;
String[] arrParameters = {"distance", "displacement-angle1", "displacement-angle2", "section", "bound", "angle1", "angle2", "velocity", "angularRate"};
int columnHeight = 67;

int stringHeight = 15;   //height of movician;

int numOfColumns = 24;
int radius = 120;
float theta=0.0f;

//to make it play song files
  //AudioPlayer song;
   //to make it "hear" audio input
  AudioInput in;
  //AudioOutput out;
   AudioRecorder recorder;
//for displaying the sound's frequency
  FFT fft;
  FFT fftLog;


//---------------------------------

int[] selectedChannels = { 
  1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16
};
OscP5 oscP5;
NetAddress myRemoteLocation;
// To send to Pd
//NetAddress myLocalLocation;
byte[] rxData;

Date d;

int colorModeStroke = 255;   //change the stroke of everything with method colorPerfMode
int colorModeBackground = 0;  //change the background with method colorPerfMode
boolean WHITEBACKGROUND = false;

void setup() {
  //size( 700, 300, P3D );    //change the size of screen if you want
  size (1300, 800, P3D);
   //size (1600, 1050, P3D);
   //size (1680, 1050, P3D);
// frameRate(fps);
//cursor(HAND);
noCursor();
  oscP5 = new OscP5(this, 9003);  // listen to port 8000
  //myRemoteLocation = new NetAddress("169.254.125.210", 9000);
  //myRemoteLocation = new NetAddress("169.254.1.1", 9000);
 // myLocalLocation = new NetAddress("localhost", 9001);
  myRemoteLocation = new NetAddress("127.0.0.1", 9003);
  //-------------------------------------------------
  cam = new PeasyCam(this, width/2,height/2,50,5);
  cam.setMinimumDistance(1);
  cam.setMaximumDistance(3000);
  background(255);
  //create the minim object
   minim = new Minim(this);
   //an FFT needs to know how 
  //long the audio buffers it will be analyzing are
  //and also needs to know 
  //the sample rate of the audio it is analyzing
  //in = minim.getLineIn(Minim.STEREO, 512);
   in = minim.getLineIn(Minim.STEREO, 1024);
   //song = minim.loadFile("Impro1.mp3", 2048);
  //fftLog = new FFT(in.bufferSize(), in.sampleRate());
  fft = new FFT(in.bufferSize(), in.sampleRate());
  //fftLog.logAverages(22, 12);
  
   players = new Player[numOfPlayers];
  for (int i =0; i<numOfPlayers; i++){
 players[i] = new Player(i);
  }
Date d = new Date();
long current = d.getTime(); 
output = createWriter(current + ".txt");
java.sql.Timestamp systemDate = new java.sql.Timestamp(current);
output.println(systemDate);
output.println("Millis()@sessionINIT: " + millis() + ", PLAYER ID : " +current + " = " + systemDate  );
String s = String.valueOf(current);
//out = minim.getLineIn();
//recordMovie(s);

//recorder = minim.createRecorder(in, s+".wav");
//recorder.beginRecord();
//println("start REC");


}
void draw() {
 
 newHarpSession();
  
}
 
  void newHarpSession(){
    
    if (HumanHarpON==true){    
    //start reading data from PD
    //define array of booleans with Player ON/OFF
    //for each player of PD see if they are active
    //if they are active, draw them
    //if they are not, they stay grey where they are
    //to shift the players arrows <>
    
    //retrieveInteraction(player);    
drawModel();
drawInteraction();
    }
else return; 
  }

void drawModel( ) {
 
  pushMatrix(); // matrix1  - Global
  translate(width/2, height/2+height/16, 0);    //action on global : center z= -20m observer position but all the model translate, to get back we need the inverse matrix
  rotateX(PI/2);                                    //action on global : rotate axis for visibility observer position
  rotateZ(frameCount*PI/1000);  // rotate all the model
  stroke(colorModeStroke,255); 
  background(colorModeBackground,0);
  fill(colorModeBackground,5);
  translate(0,0,-0.1);
  translate(0,0,-0.1);
  ellipse(0,0, 480,480);  // arena (g)round floor
  translate(0,0,0.2);
 // }


  drawPlayers();

  drawRoundHouse();    

   
  drawFFT();
         
  popMatrix(); // close matrix1
  /*
loadPixels();
    // Add window's pixels to movie
    mm.addFrame(pixels);
    if ( recorder.isRecording() )
  {
    //println("Currently recording...");
  }
  else
  {
    //println("Not recording.");
  }
  */
}




 
void drawRoundHouse(){
  
    
  
 for (int i=0; i < numOfColumns; i++){  //building the static model
   
      theta = 2*PI/numOfColumns*i;
     xBasePoint = sin(theta)*radius;   //xBasePoint  derives from theta but theta is hidden in the for loop
     yBasePoint = cos(theta)*radius;
     
    int heightOfRoof=10;
      
     
      strokeWeight(2);
      stroke(colorModeStroke, 200);
      
       strokeWeight(1);
      
      for (int k=1; k<columnHeight; k=k+1)
      {pushMatrix();
        translate(0,0,k);
        strokeWeight(1);
       ellipse(xBasePoint, yBasePoint, 3,3);
   
        popMatrix();
      }
      rectMode(CENTER);
      
      strokeWeight(1);

    pushMatrix();  // matrix2
    //translate(xBasePoint,yBasePoint,(columnHeight/2 + columnHeight/48*i)); //for spiral, to understand spiral different heights
    translate(xBasePoint,yBasePoint,columnHeight); 
    rotateZ(-theta);
    pushMatrix();
     ellipse(0, 0, 4,4);
     translate(0,0,0.5);
     ellipse(0, 0, 4,4);
   
     
    
    translate(0,0,1);
    rect(0,0,4,4);
    translate(0,0,0.5);
    rect(0,0,4,4);
  
    for (int k=0; k<heightOfRoof-2; k=k+1)
      {pushMatrix();
        translate(0,0,k);
        strokeWeight(1);
    rect(0,0,4,4);
        popMatrix();
      }   
    rect(0,0,4.5,4.5);
    popMatrix();
    //draw base
    pushMatrix();
      translate(0,0,-columnHeight);
      rect(0, 0, 5,5);
       translate(0,0,1);
       rect(0, 0, 5,5);
       ellipse(0, 0, 5,5);
       translate(0,0,0.3);
       ellipse(0, 0, 4.8,4.8);

     popMatrix();

  // close matrix2
  
 pushMatrix(); //matrix2a
//-----------draw the structure up to columnHeight
strokeWeight(1);

 line (0, 0, heightOfRoof, 32*cos(-PI/24), 32*sin(-PI/24), heightOfRoof);
 line (0, 0, heightOfRoof-1, 32*cos(-PI/24), 32*sin(-PI/24), heightOfRoof-1);
 stroke(colorModeStroke,100);
 line (0, 0, heightOfRoof+58, 32*cos(-PI/24), 32*sin(-PI/24), heightOfRoof+58);

 line (0, 0, heightOfRoof, 0, 40, heightOfRoof+39);
  line (0, 0, heightOfRoof, 0, radius, heightOfRoof);
   line (0, 40, heightOfRoof, 0, 40, heightOfRoof+39);
   line (0, 40, heightOfRoof, 0, 80, heightOfRoof+19.5);
   line (0, 80, heightOfRoof, 0, 80, heightOfRoof+19.5);

 line (0, 0, heightOfRoof, 0, 0, heightOfRoof+58);
 line (0, 120, heightOfRoof, 0, -55, 95);

 stroke(colorModeStroke,255);
 rectMode(CENTER);
 rotateY(+PI/2);
 translate(4,-120,0);
 noFill();
 arc(0, 0, 240, 240, PI/2+PI/28, PI/2+PI/28+PI/4, OPEN);
 
 translate(4,120,0);
 rotateY(-PI/2);
 rotateZ(-PI/24);
 
 
  translate(15.7,0,0);
 rotateX(PI/2);
 noFill();

 translate(0,6,0);

  
  arc(0,0, 28, 21, PI/9, PI-(PI/9), OPEN);
  
   ellipse(-11.5,+9,4,4); 
 ellipse(11.5,+9,4,4); 
 ellipse(-12.9,+6,2,2); 
 ellipse(12.9,+6,2,2); 
 ellipse(-8.6,+9.8,2,2); 
 ellipse(8.6,9.8,2,2); 


 popMatrix(); //close matrix2a
 popMatrix(); //close matrix2
} 
  
}


void drawFFT(){
  
  fft.forward(in.mix);

 pushMatrix();  //  matrix3

   
    translate(0,0,0); //for spiral, to understand spiral different heights
    
        stroke(colorModeStroke,5);
        rotateX(-PI/2);
       
        rotateZ(-PI/2);
        
 
        
        
//-------AUDIO ANALYSIS--------TO BE UPDATED
  for(int i=0; i < fft.specSize(); i++){
   
        
       leftShift= int(map(in.left.get(i),-0.5, 0.5, -12, 0));
       rightShift= int(map(in.right.get(i),-0.5, 0.5, 0, +12));
        
      
         float x = log2(20*i)*6 ;
      
         float y = fft.getBand(i);
    
        //float y = log2(fft.getBand(i))*100;
        //float y = fftLog.getAvg(i)*spectrumScale;
        
        float yD = map (y, 0, 500, 0, columnHeight);
        int alpha = int(map (yD, 0, columnHeight, 30, 180));
       
      //fill(alpha,green,blue,alpha);
      colorMode(HSB, 255);
    
     strokeWeight(1);
      stroke(colorModeStroke, 255);
   
    pushMatrix();
    translate(x, 0,0);
    rotateY(PI/2);
    colorMode(HSB);
    stroke(int(map ((log2(fft.indexToFreq(i)/55)*100)%100,0,100,0,255)),200,int(map ((log2(fft.indexToFreq(i))),0,14,20,255)),map(y, 0, 10, 0, 255));
     ellipse (0,0, y,y);
     stroke(colorModeStroke, map(y, 0, 10, 0, 255));
      ellipse (0,0, y+20+y/2,y+20+y/2);
    pushMatrix();
    rotateZ(frameCount*(y*i*2*PI/fft.specSize()));
    colorMode(RGB);
    stroke(colorModeStroke,map(y, 0, 10, 0, 255));
     
    line(y, 0, 0, radius*cos (i*2*PI/fft.specSize()), radius*sin (i*2*PI/fft.specSize()), (columnHeight+10)-x);
      
      noFill();
  
     popMatrix();
    popMatrix();
   
     
   
    
     
     if ( fft.getBand(i)> 2){
        
        stroke(colorModeStroke, 5);
  
      }
      colorMode(RGB, 255);

     if (keyPressed) {
     if (key == ' ') {
       noStroke();
       fill (colorModeBackground, 5);
       rect (0,0,width+800,height+800);

    }
     }
  
  }           
  popMatrix();  //  close matrix3  
  
}



 
  boolean checkPlayers(int id){
    boolean ID_ACTIVE = false;
    if ((players[id].playerIsAwake())==true){  
    //print(players[id].playerId + " is Awake: ");
    //print(players[id].distance + " - distance; ");
    //print(players[id].displacementAngle1 + " - disAngle1; ");
    //println(players[id].displacementAngle2 + " - disAngle2; ");
    ID_ACTIVE=true;
    }
    return ID_ACTIVE;
  }
  
   void drawInteraction(){  
    
    for (int i=0; i<12; i++){
        drawPlayerPos(i);    //update relative player position (X axis is ID-column to centerOfRoundhouse, theta is relative angle)

  }
  } 
  
  void drawPlayerPos(int  id){
    strokeWeight(3);
    stroke(colorModeStroke);
    textSize(32);
  
    colorMode(HSB, 255);
      fill(255*id/numOfPlayers, 200,200, 255);
      stroke(255*id/numOfPlayers, 200,200, 255);
    text(" HUMAN HARP VISUALIZATION - Roundhouse Live Lab - Alessia Milo - MAT - Queen Mary" ,-width/2,height+height/16); 
    text(" Play Human Harp and watch your movician perform in the Roundhouse   " ,-width/2,-height/16); 
       
    text( id+101 + " :dist: m " + (players[id].distance/10)+" :dA1 deg: "+ (players[id].angle1)+ " :dA2 deg: "+ (players[id].angle2), int(players[id].distance)-width/2,height/numOfPlayers*id); 
    
    line (  -width/2,   height/numOfPlayers*id,  0, -width/2+(players[id].distance*10), height/numOfPlayers*id+(players[id].distance*10*sin(players[id].angle2)),(players[id].distance*10)*sin(players[id].angle1));
    
   
  }

  void keyPressed() {
 if (key == 'w') {
   if (WHITEBACKGROUND==true){
     WHITEBACKGROUND=false;
     colorPerfMode();
     println("white OFF");}
     else {WHITEBACKGROUND=true;
     colorPerfMode();
     println("white ON");}   
 }
     if (key == 'p') {
  output.flush();  // Writes the remaining data to the file
  output.close();  // Finishes the file
  // Finish the movie if space bar is pressed
   // mm.finish();
    println(" stop recording: ");
      // we've filled the file out buffer, 
    // now write it to the file we specified in createRecorder
    // in the case of buffered recording, if the buffer is large, 
    // this will appear to freeze the sketch for sometime
    // in the case of streamed recording, 
    // it will not freeze as the data is already in the file and all that is being done
    // is closing the file.
    // the method returns the recorded audio as an AudioRecording, 
    // see the example  AudioRecorder >> RecordAndPlayback for more about that
    //recorder.save();
    println("Done saving.");
    // Quit running the sketch once the file is written
    //exit();
  exit();  // Stops the program
     }
    if (key == CODED) {
      if (keyCode == LEFT) { 
        playerHighLighted = playerHighLighted-1;
        if (playerHighLighted<0){
          playerHighLighted=11;
        }
      }
       if (keyCode == RIGHT) {   
         playerHighLighted = playerHighLighted+1;
        if (playerHighLighted==12){
          playerHighLighted=0;
        }
      }
      if (keyCode == UP) {
        if(players[playerHighLighted].playerHeight==columnHeight||players[playerHighLighted].playerHeight>columnHeight){
          players[playerHighLighted].playerHeight=columnHeight;
        }else{players[playerHighLighted].playerHeight=players[playerHighLighted].playerHeight+10;}  
        }
     if (keyCode == DOWN) {
        if(players[playerHighLighted].playerHeight==0||players[playerHighLighted].playerHeight<0){
          players[playerHighLighted].playerHeight=0;
        }else{players[playerHighLighted].playerHeight=players[playerHighLighted].playerHeight-10;}  
       
        }
    }
      }

void drawPlayers(){
  for (int j=0; j < numOfPlayers; j++){ 
     //--------DRAW THE PLAYER-----------
      //CREATE FUNCTION EVERY COLUMN
      theta = 2*PI/numOfColumns*j;
        if(j==playerHighLighted){strokeWeight(5);}
      else{strokeWeight(1);}

      pushMatrix();
       rotateZ(theta);
       translate(0,radius,0);
      translate(0,0,players[j].playerHeight);
      
      rotateX(-PI/2);
      rotateY(PI);
      rotateZ(PI/2);
      //----------------------
      stroke(colorModeStroke);

      
    float XL =  (players[j].distance+4)*cos(radians(players[j].angle1));
    float YL =   (players[j].distance+4)*sin(radians(players[j].angle2));
    float ZL =   (players[j].distance+4)*sin(radians(players[j].angle1));
      
      
       line (0, 0, 0, XL,YL,ZL);
       line (players[j].playerHeight, YL, 0, players[j].playerHeight, YL, ZL);
       line (players[j].playerHeight, 0, 0, players[j].playerHeight, YL, 0);
       line (players[j].playerHeight, 0, ZL, players[j].playerHeight, YL, ZL);
       line (players[j].playerHeight, 0, 0, players[j].playerHeight, 0, ZL);
       
       strokeWeight(3);
       stroke(255*j/numOfPlayers, 255,200,255);
       line (XL, YL, ZL, players[j].playerHeight, YL, ZL);
       
       pushMatrix();
       translate(players[j].playerHeight,YL,ZL);
         int movHeight=16;
      
       for (int k=0; k<movHeight; k=k+2)
      {//
     pushMatrix();
        translate(-k,0,0);
        rotateY(PI/2);
        stroke(colorModeStroke, 255);
        strokeWeight(1);
        fill(255*j/numOfPlayers, 255,200,50);
        ellipse(0, 0, 5-k*5/6,5-k*5/6);
        popMatrix();
      }
      popMatrix();
      noFill();
   
       colorMode (HSB, 255);
    stroke(colorModeStroke);
       stroke(255*j/numOfPlayers, 255,200,255);
    rotateX(PI/2);
rotateX(-PI/2);
      drawIntertrajectory(j, ZL);
  
    
      //-------------------------
      rotateZ(-PI/2);
      rotateY(-PI);
      rotateX(PI/2);
     
      translate(0,0,-players[j].playerHeight);
      translate(0,-radius,0);
       rotateZ(-theta);
       popMatrix();
 
}
}
void drawIntertrajectory(int j, float ZL){
 
  pushMatrix();
  strokeWeight(1);
  stroke(colorModeStroke);
  
  rotateY(-radians(players[j].angle1));
  rotateZ(radians(players[j].angle2));
   
  line (0,0,0, players[j].distance, 0,0);
 
  for(int t=0; t<players[j].distance; t++){
    
    translate(t,0,0);
    rotateX(radians(frameCount+players[j].velocity/10%360));
   
    
  drawInterObject(j, t);
   translate(-t,0,0);
  }
  
  popMatrix();
}

void drawInterObject(int j, int t){
  ellipseMode(CORNER);
    colorMode(HSB, 255);
 rotateY(PI/2);
   //if(players[j].velocity>0){stroke(colorModeStroke,255);}
   //else{stroke(150,255);}
     stroke(255*j/numOfPlayers, int(map(players[j].velocity, -100, 100, 100,255)),200, int(map(abs(players[j].velocity), 0, 100, 100,255)));
  ellipse(players[j].angularRate/10, players[j].velocity/10,  (players[j].distance/100+t/10)+(players[j].velocity/10)*radians(0.5+players[j].angle2), (players[j].distance/100+t/10)+players[j].velocity/10*radians(0.5+players[j].angle1));
rotateY(-PI/2);
  ellipseMode(CENTER);
noFill();
}

void getDate(){
  long current = d.getTime(); 
java.sql.Timestamp systemDate = new java.sql.Timestamp(current);
rd = String.valueOf(systemDate);
  
}

void colorPerfMode(){
  if (WHITEBACKGROUND == true){
    colorModeStroke = 0;
    colorModeBackground = 255;
  }
  else{
    colorModeStroke = 200;
    colorModeBackground = 0;
  } 
}
//----OSC FUNCTIONS----------------------------------


//----MINIM FUNCTIONS------------------------------------
void stop()
{
  //close the AudioPlayer you got from Minim.loadFile()
    in.close();
  
    minim.stop();
    //mm.finish();
 
  //this calls the stop method that 
  //you are overriding by defining your own
  //it must be called so that your application 
  //can do all the cleanup it would normally do
    super.stop();
}
//LOG
float log2 (int x) {
  return (log(x) / log(2));
}
float log2 (float x) {
  return (log(x) / log(2));
}


//----SENDING FUNCTIONS----------------------------------
void oscEvent(OscMessage theOscMessage)
{
  //println("### received an osc message. with address pattern "+
          //theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
 //getDate();
    parameter=theOscMessage.addrPattern().substring(5);
    //switchPanel(parameter);
 //println(parameter);
   //get the index in the section array of the next section to be loaded
    index = java.util.Arrays.asList(arrParameters).indexOf(parameter);
    //print( "index = " + index);
   playerNumber=int(theOscMessage.addrPattern().substring(1,4))-101;
   //print( ", playerNum = " + playerNumber);
   if(theOscMessage.checkTypetag("i")){
   value= float(theOscMessage.get(0).intValue());
   }
   else if (theOscMessage.checkTypetag("f")){
     value= theOscMessage.get(0).floatValue();
   }
   
   switch(index)
    {
      case 0:   
    players[playerNumber].setDistance(value);
   output.println("millis: " + millis()+ ", ID= " + playerNumber + ", distance = " + players[playerNumber].distance);
    //println(frameCount + ", ID= " + playerNumber + ", distance = " + players[playerNumber].distance);
        break;
      case 1:
       players[playerNumber].setDisplacementAngle1(value);
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", displacement-angle1 = " + value);
       //println(" ID= " + playerNumber + ", displacement-angle1 = " + value);
        break;
      case 2:
        players[playerNumber].setDisplacementAngle2(value);
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", displacement-angle2 = " + value);
        //println(" ID= " + playerNumber + ", displacement-angle2 = " + value);
        break;
      case 3:
        players[playerNumber].setSection(value);
      output.println("millis: " + millis()+ ", ID= " + playerNumber + ", section = "+ value);
        break;
      case 4:
        players[playerNumber].setBound(value);
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", bound = "+ value);
        break;
         case 5:
       players[playerNumber].setAngle1(value);
        //players[playerNumber].setAngle1();
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", angle1 = "+ value);
       //println( frameCount+ ", ID= " + playerNumber + ", angle1 = "+ value);
        break;
         case 6:
       players[playerNumber].setAngle2(value);
        //players[playerNumber].setAngle2();
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", angle2 = "+ value);
         //println( frameCount+ ", ID= " + playerNumber + ", angle2 = "+ value);
        break;
          case 7:
         players[playerNumber].setVelocity(value);
        //players[playerNumber].setVelocity();
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", velocity = "+ value);
         //println( frameCount+ ", ID= " + playerNumber + ", velocity = "+ value);
        break;
          case 8:
        //players[playerNumber].setAngularRate(value);
         players[playerNumber].setAngularRate();
        output.println("millis: " + millis()+ ", ID= " + playerNumber + ", angularRate = "+ value );
        //println( frameCount+ ", ID= " + playerNumber + ", angularRate = "+ value );
        break;
    }
  //println( ", value = " + value);
  //println("### received an osc message. with address pattern "+
         // theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
   //println( "  ");
    //Check from the index which section we have to load next
   
    }
