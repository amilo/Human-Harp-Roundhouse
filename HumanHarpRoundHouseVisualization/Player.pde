//class that defines the data from Human Harp Player

class Player {
  
  int playerId;
  float distance;
  float distanceMeters;
  float angle1;
  float angle2; 
  float displacementAngle1;
  float displacementAngle2;  
  float section;
  float bound;
  float velocity;
  float angularRate;
 
  boolean AWAKE=false; // /ON/OFF
  float storedDist=0;
  float storedAngle1=0;
  float storedAngle2=0;
  int count=0;
  int sleepTreshold=10;
  int playerHeight=0;
  

 
   

  
  Player(int index){
    
    //constructor
    this.playerId=index;  //parse index directly from pd index
    this.distance=0.0f;
    this.displacementAngle1=0.0f;
    this.displacementAngle2=0.0f;
    this.section=0.0f;
    this.bound=0.0f;
    this.angle1=0.0f;
    this.angle2=0.0f;
    this.velocity=0.0f;
    this.angularRate=0.0f;
    
    this.storedDist=distance;
    this.storedAngle1=displacementAngle1;
    this.storedAngle2=displacementAngle2;
    this.playerHeight=columnHeight/2;
    //autoMode();
    

   
     
  }
  
  int getId(){    
  return playerId; 
  }

  void changeId(int index){  //to assign players to specific sonic personas
  playerId=index; 
  }
  void setPlayerHeight(int x){
  playerHeight=x; 
  } 
  void setDistance(float x){
  distance=(x/780); //units = dm
  }

   
  void setDisplacementAngle1(float x){
  displacementAngle1=x; 
  } 
  void setDisplacementAngle2(float x){
   displacementAngle2=x; 
  } 
  void setSection(float x){
   section=x; 
  } 
  void setBound(float x){
   bound=x; 
  } 
    
   void setAngle1(float x){
     
   angle1=-x;  
   //println(angle1);
   
  } 
   void setAngle2(float x){
   angle2=-x; 
   //println(angle2);
   //angle2=x*100;
  } 
   void setVelocity(float x){
   velocity=x/100; 
  }
  
   void setAngularRate(float x){
   angularRate=x/100; 
  }
  
    void setDistance(){
  distance=frameCount%360; //units = dm
  }  
  
   void setVelocity(){
     
     velocity = frameCount%20;
     //println(velocity);
  
  }
   void setAngle1(){
    
   angle1=radians((frameCount*5)%360); 
  } 
   void setAngle2(){
     //println("method1");
     //angle2=PI/2; 
    angle2=radians((frameCount*5)%360); 
  
  } 
  void setAngularRate(){
   angularRate=radians(frameCount%360); 
  }  

  boolean playerIsAwake(){
  //------------------------------SIMPLE VERSION
  
    if (frameCount%2==0){
    storeDistance();
    }
    if (frameCount%2==1){
    evaluateV();
    }   
  return AWAKE;  
  }

  void storeDistance(){
    storedDist = distance;
    storedAngle1 = displacementAngle1;
    storedAngle2 = displacementAngle2;
  }

  void evaluateV(){   
   float v = abs(distance-storedDist);
   float va1 = abs(displacementAngle1-storedAngle1);
   float va2 = abs(displacementAngle2-storedAngle2);
 
    if (v+va1+va2<=1){                           //if the absolute sum of all the values is below 1: start counting to fall asleep
    count = count+1;
    sleepMonitor(count);                        //check the sleeping/awake condition    
  } 
     else {
     count=0;  
     AWAKE = true;                               //println(playerId + ":ID WAKE UP" );
   }
  }
  
  boolean sleepMonitor(int x){                    //takes counter number and compare to sleeping treshold
  
    if (x<sleepTreshold){    
    AWAKE = true;                              //println(playerId + ":ID " + count + "FALLING ASLEEP");
     }
    else if (x==sleepTreshold){     
    AWAKE = false;                              //println(playerId + ":ID ASLEEP" );
     }
     else if (x>sleepTreshold){    
    AWAKE = false;                              //println(playerId + ":ID SLEEPING" );
     }
   return AWAKE;
  }
  
  void autoMode(){
    setDistance();
    setVelocity();
    setAngle1();
    setAngle2();
    setAngularRate();
  }


}
