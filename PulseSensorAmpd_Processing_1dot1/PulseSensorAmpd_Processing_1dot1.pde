/*
THIS PROGRAM WORKS WITH PulseSensorAmped_Arduino-xx ARDUINO CODE
THE PULSE DATA WINDOW IS SCALEABLE WITH SCROLLBAR AT BOTTOM OF SCREEN
PRESS 'S' OR 's' KEY TO SAVE A PICTURE OF THE SCREEN IN SKETCH FOLDER (.jpg)
MADE BY JOEL MURPHY AUGUST, 2012
*/
import java.util.*;
import processing.serial.*;
import processing.video.*;
Capture webcam;

PFont font;
Scrollbar scaleBar;

Serial port;  

//Serial port_2;
int flag=0; // flag = 1 when green light is displayed
int counter = 0;
int Sensor;      // HOLDS PULSE SENSOR DATA FROM ARDUINO
int Sensor2;
int IBI;         // HOLDS TIME BETWEN HEARTBEATS FROM ARDUINO
int BPM;         // HOLDS HEART RATE VALUE FROM ARDUINO
int[] RawY;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING
int[] RawY2;      // HOLDS HEARTBEAT WAVEFORM DATA BEFORE SCALING

int[] ScaledY;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] ScaledY2;   // USED TO POSITION SCALED HEARTBEAT WAVEFORM
int[] rate;      // USED TO POSITION BPM DATA WAVEFORM
float zoom;      // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
float offset;    // USED WHEN SCALING PULSE WAVEFORM TO PULSE WINDOW
color eggshell = color(255, 253, 245);
color temp = color(255,0,0);

int heart = 0;   // This variable times the heart image 'pulse' on screen
//  THESE VARIABLES DETERMINE THE SIZE OF THE DATA WINDOWS
int PulseWindowWidth = 490;
int PulseWindowHeight = 512; 
int BPMWindowWidth = 180;
int BPMWindowHeight = 340;
boolean beat = false;    // set when a heart beat is detected, then cleared when the BPM graph is advanced
PrintWriter output;
PrintWriter SensorOut;
PrintWriter SensorOut2;

//PrintWriter SensorOut_2;
int time;
int wait = 5000;

void setup() {
  
  size(900, 900);  // Stage size
  frameRate(100);  
  font = loadFont("Arial-BoldMT-24.vlw");
  textFont(font);
  textAlign(CENTER);
  rectMode(RADIUS);
  ellipseMode(CENTER);  
// Scrollbar constructor inputs: x,y,width,height,minVal,maxVal
  scaleBar = new Scrollbar (400, 575, 180, 12, 0.5, 1.0);  // set parameters for the scale bar
  RawY = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  RawY2 = new int[PulseWindowWidth];          // initialize raw pulse waveform array
  ScaledY = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  ScaledY2 = new int[PulseWindowWidth];       // initialize scaled pulse waveform array
  rate = new int [BPMWindowWidth];           // initialize BPM waveform array
  zoom = 0.75;  // initialize scale of heartbeat window
   time=millis();
  //SensorOut = createWriter("sensor.txt" );
  //SensorOut = createWriter("sensor.xlsx" );
  SensorOut = createWriter("Dc_input/heart_top"+".csv" );
  SensorOut2 = createWriter("Dc_input/heart_bottom"+".csv" );
  
// set the visualizer lines to 0
 for (int i=0; i<rate.length; i++){
    rate[i] = 555;      // Place BPM graph line at bottom of BPM Window 
   }
 for (int i=0; i<RawY.length; i++){
    RawY[i] = height/2; // initialize the pulse window data line to V/2
 }
 for (int i=0; i<RawY2.length; i++){
    RawY2[i] = height/2; // initialize the pulse window data line to V/2
 }
   
// GO FIND THE ARDUINO
  //println(Serial.list());    // print a list of available serial ports
  // choose the number between the [] that is connected to the Arduino
  
  //////
  port = new Serial(this, Serial.list()[0], 115200);  // make sure Arduino is talking serial at this baud rate
  
  //port_2 = new Serial(this, Serial.list()[1], 115200);
  //////
  
  port.clear();            // flush buffer
  //port_2.clear();
  port.bufferUntil('\n');  // set buffer full flag on receipt of carriage return
  //port_2.bufferUntil('\n');

}

void draw() {
  background(0);
  noStroke();
// DRAW OUT THE PULSE WINDOW AND BPM WINDOW RECTANGLES  
  fill(eggshell);  // color for the window background
  rect(255,height/2,PulseWindowWidth+400,PulseWindowHeight);

// DRAW THE PULSE WAVEFORM
  // prepare pulse data points 
  
  RawY[RawY.length-1] = (1023 - Sensor) - 212;   // place the new raw datapoint at the end of the array
  RawY2[RawY2.length-1] = (1023 - Sensor2) - 212;   // place the new raw datapoint at the end of the array
  
  zoom = scaleBar.getPos();                      // get current waveform scale value
  offset = map(zoom,0.5,1,150,0);                // calculate the offset needed at this scale
    
  
  for (int i = 0; i < RawY.length-1; i++) {      // move the pulse waveform by
    RawY[i] = RawY[i+1]; // shifting all raw datapoints one pixel left
    if (counter >= 150){
      
    Date d = new Date();
    
    print(millis(),time,wait,"\n");
    if(millis()-time >=wait){
      time=millis();
      if(flag == 1){
        flag = 0;
        wait = 5000;
        rect(500,800,500,150);
        fill(255,0,0);
        temp= color(255,0,0);
      }
      else{
       flag = 1;
       wait = 2000;
       rect(500,800,500,150);
       temp = color(0,255,0);
      }
    }
    rect(500,800,500,150);
    fill(temp);
    
    SensorOut.println(Sensor + ", " +  d.getTime() +","+ flag );
    counter = 0;
    }else{
      counter++;
    }
    float dummy = RawY[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
  }
  stroke(0,0,0);                               // black is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY.length-1; x++) {  
    //print(ScaledY[x],"\n");
    //if(ScaledY[x]>400)
      vertex(x+10, ScaledY[x]+0);//draw a line connecting the data points
    //black on graph sensor one
  }
  endShape();
  for (int i = 0; i < RawY2.length-1; i++) {      // move the pulse waveform by
    RawY2[i] = RawY2[i+1]; // shifting all raw datapoints one pixel left
    if (counter >= 150){
    //////////
    Date d = new Date();
    SensorOut2.println(Sensor2 + ", " +  d.getTime()+","+flag);
    counter = 0;
    }else{
      counter++;
    }
    float dummy = RawY2[i] * zoom + offset;       // adjust the raw data to the selected scale
    ScaledY2[i] = constrain(int(dummy),44,556);   // transfer the raw data array to the scaled array
  }
  stroke(250,0,0);                               // red is a good color for the pulse waveform
  noFill();
  beginShape();                                  // using beginShape() renders fast
  for (int x = 1; x < ScaledY2.length-1; x++) {    
    vertex(x+10, ScaledY2[x]-150);                    //draw a line connecting the data points
    //red on graph sensor 2
  }
  endShape();
//// DRAW THE BPM WAVE FORM
//// first, shift the BPM waveform over to fit then next data point only when a beat is found
// if (beat == true){   // move the heart rate line over one pixel every time the heart beats 
//   beat = false;      // clear beat flag (beat flag waset in serialEvent tab)
//   for (int i=0; i<rate.length-1; i++){
//     rate[i] = rate[i+1];                  // shift the bpm Y coordinates over one pixel to the left
//   }
//// then limit and scale the BPM value
//   BPM = min(BPM,200);                     // limit the highest BPM value to 200
//   float dummy = map(BPM,0,200,555,215);   // map it to the heart rate window Y
//   rate[rate.length-1] = int(dummy);       // set the rightmost pixel to the new data point value
// } 
// stroke(0,150,250);                               // red is a good color for the pulse waveform
//  noFill();
//  beginShape(PulseWindowWidth);                                  // using beginShape() renders fast
//  for (int x = 1; x < ScaledY2.length-1; x++) {    
//    vertex(x+10, ScaledY2[x]);                    //draw a line connecting the data points
//  }
  //////GRAPH THE HEART RATE WAVEFORM
 //////troke(250,250,250);                          // color of heart rate graph
 //////trokeWeight(2);                          // thicker line is easier to read
 //////oFill();
 //////eginShape(PulseWindowWidth);
 //////or (int i=0; i < rate.length-1; i++){    // variable 'i' will take the place of pixel x position   
  ////// //vertex(i+10, rate[i]);                 // display history of heart rate datapoints
 //////
 
 
///

// PRINT THE DATA AND VARIABLE VALUES
  fill(0);                                       // get ready to print text
  text("Pulse Sensor Amped Visualizer 1.1",245,30);      // tell them what you are
  //text("IBI " + IBI + "mS ",600,585);                    // print the time between heartbeats in mS
  fill(0);
  text(BPM + " BPM",600,200,545,30);                           // print the Beats Per Minute
  
  //text("Pulse Window Scale " + nf(zoom,1,2), 150, 585); // show the current scale of Pulse Window
    //DO THE SCROLLBAR THINGS
  scaleBar.update (mouseX, mouseY);
  scaleBar.display();
 }