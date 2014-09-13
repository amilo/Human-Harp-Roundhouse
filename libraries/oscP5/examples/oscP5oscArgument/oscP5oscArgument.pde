/**
 * oscP5oscArgument by andreas schlegel
 * example shows how to parse incoming osc messages "by hand".
 * it is recommended to take a look at oscP5plug for an alternative way to parse messages.
 * oscP5 website at http://www.sojamo.de/oscP5
 */

import oscP5.*;
import netP5.*;

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(400,400);
  frameRate(25);
  /* start oscP5, listening for incoming messages at port 12000 */
  oscP5 = new OscP5(this,9005);
  myRemoteLocation = new NetAddress("localhost",9005);
  /* send an OSC message to this sketch */
  //oscP5.send("/test",new Object[] {new Integer("1"), new Float(2.0),"test string."}, myRemoteLocation);
  
}

void draw() {
  background(0);  
}

void oscEvent(OscMessage theOscMessage) {

  println("### received an osc message. with address pattern "+
          theOscMessage.addrPattern()+" typetag "+ theOscMessage.typetag());
}
