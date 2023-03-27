import java.util.ArrayList;
import java.util.Collections;

//these are variables you should probably leave alone
int index = 0; //starts at zero-ith trial
float border = 0; //some padding from the sides of window, set later
int trialCount = 10; //WILL BE MODIFIED FOR THE BAKEOFF
 //this will be set higher for the bakeoff
int trialIndex = 0; //what trial are we on
int errorCount = 0;  //used to keep track of errors
float errorPenalty = 1.0f; //for every error, add this value to mean time
int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false; //is the user done
boolean mouseDrag = false;

final int screenPPI = 72; //what is the DPI of the screen you are using
//you can test this by drawing a 72x72 pixel rectangle in code, and then confirming with a ruler it is 1x1 inch. 

//These variables are for my example design. Your input code should modify/replace these!
float logoX = 500;
float logoY = 500;
float logoZ = 50f;
float logoRotation = 0;

private class Destination
{
  float x = 0;
  float y = 0;
  float rotation = 0;
  float z = 0;
}

class ScrollBar {
  int swidth, sheight;    // width and height of bar
  float xpos, ypos;       // x and y position of bar
  float spos, newspos;    // x position of slider
  float sposMin, sposMax; // max and min values of slider
  int loose;              // how loose/heavy
  boolean over;           // is the mouse over the slider?
  boolean locked;
  float ratio;
  float scale;
  
  ScrollBar (float xp, float yp, int sw, int sh, int l) {
    swidth = sw;
    sheight = sh;
    int widthtoheight = sw - sh;
    ratio = (float)sw / (float)widthtoheight;
    xpos = xp;
    ypos = yp-sheight/2;
    spos = xpos + sw / 2 - sheight/2;
    newspos = spos;
    sposMin = xpos;
    sposMax = xpos + swidth - sheight;
    loose = l;
    locked = false;
    scale = 1;
  }

  void update() {
    if (overEvent()) {
      over = true;
    } else {
      over = false;
    }
    if (mousePressed && over) {
      locked = true;
    }
    if (!mousePressed) {
      locked = false;
    }
    if (locked) {
      newspos = constrain(mouseX-sheight/2, sposMin, sposMax);
    }
    if (abs(newspos - spos) > 1) {
      scale = (newspos - spos)/loose*logoZ/60;
      logoZ += scale;
      spos = spos + (newspos-spos)/loose;
    }
  }

  float constrain(float val, float minv, float maxv) {
    return min(max(val, minv), maxv);
  }

  boolean overEvent() {
    if (mouseX > spos - sheight / 2 && mouseX < spos+sheight / 2 &&
      mouseY > ypos && mouseY < ypos+sheight) {
      return true;
    } else {
      return false;
    }
  }

  void display() {
    noStroke();
    fill(200);
    rect(sposMin, ypos, sposMax, sheight);
    if (over || locked) {
      fill(0, 255, 0);
    } else {
      fill(255, 0, 255);
    }
    rect(spos, ypos, sheight, sheight);
  }

  float getPos() {
    // Convert spos to be values between
    // 0 and the total width of the scrollbar
    return spos * ratio;
  }

  float getScale() {
    return (spos - xpos) / (swidth / 2.0);
  }
}

ArrayList<Destination> destinations = new ArrayList<Destination>();
ScrollBar scroll;

void setup() {
  size(1000, 800);  
  rectMode(CENTER);
  textFont(createFont("Arial", inchToPix(.3f))); //sets the font to Arial that is 0.3" tall
  textAlign(CENTER);
  rectMode(CENTER); //draw rectangles not from upper left, but from the center outwards
  
  //don't change this! 
  border = inchToPix(2f); //padding of 1.0 inches

  // set up scroll bar
  scroll = new ScrollBar(0, height - 16, width / 2, 16, 2);

  println("creating "+trialCount + " targets");
  for (int i=0; i<trialCount; i++) //don't change this! 
  {
    Destination d = new Destination();
    d.x = random(border, width-border); //set a random x with some padding
    d.y = random(border, height-border); //set a random y with some padding
    d.rotation = random(0, 360); //random rotation between 0 and 360
    int j = (int)random(20);
    d.z = ((j%12)+1)*inchToPix(.25f); //increasing size from .25 up to 3.0" 
    destinations.add(d);
    println("created target with " + d.x + "," + d.y + "," + d.rotation + "," + d.z);
  }

  Collections.shuffle(destinations); // randomize the order of the button; don't change this.
}



void draw() {

  background(40); //background is dark grey
  fill(200);
  noStroke();
 
  //Test square in the top left corner. Should be 1 x 1 inch
  //rect(inchToPix(0.5), inchToPix(0.5), inchToPix(1), inchToPix(1));

  //shouldn't really modify this printout code unless there is a really good reason to
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, inchToPix(.4f));
    text("User had " + errorCount + " error(s)", width/2, inchToPix(.4f)*2);
    text("User took " + (finishTime-startTime)/1000f/trialCount + " sec per destination", width/2, inchToPix(.4f)*3);
    text("User took " + ((finishTime-startTime)/1000f/trialCount+(errorCount*errorPenalty)) + " sec per destination inc. penalty", width/2, inchToPix(.4f)*4);
    return;
  }

  //===========DRAW DESTINATION SQUARES=================
  for (int i=trialIndex; i<trialCount; i++) // reduces over time
  {
    pushMatrix();
    Destination d = destinations.get(i); //get destination trial
    translate(d.x, d.y); //center the drawing coordinates to the center of the destination trial
    
    rotate(radians(d.rotation)); //rotate around the origin of the Ddestination trial
    noFill();
    strokeWeight(3f);
    if (trialIndex==i) {
      stroke(255, 0, 0, 192); //set color to semi translucent
      boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f);
      if (checkForSuccess()) {
        stroke(0, 255, 0, 192); 
      } else if (closeDist) { // if in center turn blue
        stroke(255, 255, 0, 192); 
      }
    }
    else
      stroke(128, 128, 128, 128); //set color to semi translucent
    rect(0, 0, d.z, d.z);
    popMatrix();
  }

  //===========DRAW LOGO SQUARE=================
  pushMatrix();
  if (mouseDrag) {
    logoX = mouseX;
    logoY = mouseY;
  }
  translate(logoX, logoY);
  rotate(radians(logoRotation)); //rotate using the logo square as the origin
  noStroke();
  fill(60, 60, 200, 200);
  rect(0, 0, logoZ, logoZ);
  popMatrix();

  //===========DRAW EXAMPLE CONTROLS=================
  fill(255);
  scaffoldControlLogic(); //you are going to want to replace this!
  text("Trial " + (trialIndex+1) + " of " +trialCount, width/2, inchToPix(.8f));
}

//my example design for control, which is terrible
void scaffoldControlLogic()
{  
  //lower right corner, rotate counterclockwise
  fill(255, 255, 255);
  rect(inchToPix(1.6f), height-inchToPix(.9f), inchToPix(.8f), inchToPix(.8f));
  fill(0, 0, 0);
  text("CCW", inchToPix(1.6f), height-inchToPix(.8f));
  if (mousePressed && inchToPix(1.2f) < mouseX && mouseX < inchToPix(2.0f) &&
      height-inchToPix(1.3f) < mouseY && mouseY < height-inchToPix(.5f))
    logoRotation--;

  //lower right corner, rotate clockwise
  fill(255, 255, 255);
  rect(inchToPix(.8f), height-inchToPix(.9f), inchToPix(.8f), inchToPix(.8f));
  fill(0, 0, 0);
  text("CW", inchToPix(.8f), height-inchToPix(.8f));
  if (mousePressed && inchToPix(.4f) < mouseX && mouseX < inchToPix(1.2f) &&
      height-inchToPix(1.3f) < mouseY && mouseY < height-inchToPix(.5f))
    logoRotation++;

  textSize(20);
  //lower right corner, decrease Z
  /*fill(255, 255, 255);
  rect(width-inchToPix(.8f), height-inchToPix(.5f), inchToPix(.4f), inchToPix(.4f));
  fill(0, 0, 0);
  text("-", width-inchToPix(.8f), height-inchToPix(.4f));
  xif (mousePressed && width-inchToPix(.99f) < mouseX && mouseX < width - inchToPix(.6f) &&
      mouseY > height-inchToPix(.7f))
    logoZ = constrain(logoZ-inchToPix(.02f), .01, inchToPix(4f));*/ //leave min and max alone!

  //lower right corner, increase Z
  /*fill(255, 255, 255);
  rect(width-inchToPix(.4f), height-inchToPix(.5f), inchToPix(.4f), inchToPix(.4f));
  fill(0, 0, 0);
  text("+", width-inchToPix(.4f), height-inchToPix(.4f));
  if (mousePressed && width-inchToPix(.6f) < mouseX && mouseX < width - inchToPix(.2f) &&
      mouseY > height-inchToPix(.7f))
    logoZ = constrain(logoZ+inchToPix(.02f), .01, inchToPix(4f)); //leave min and max alone!
  */

  fill(255, 255, 255);
  rect(width/5, height-inchToPix(1f), inchToPix(1f), inchToPix(.5f));
  fill(0, 0, 0);
  text("next", width/5, height-inchToPix(.9f));
  
  //check to see if user clicked next button which is used as a submit button
  if (mousePressed && width/5 - inchToPix(.5f) < mouseX &&  mouseX < width/5 + inchToPix(.5f) &&
      height-inchToPix(1.05f) < mouseY && mouseY < height-inchToPix(.5f))
  {
    if (userDone==false && !checkForSuccess())
      errorCount++;

    trialIndex++; //and move on to next trial

    if (trialIndex==trialCount && userDone==false)
    {
      userDone = true;
      finishTime = millis();
    }
    mousePressed = false;
  }
   
  scroll.display();
  scroll.update();
}

void mousePressed()
{
  if (startTime == 0) //start time on the instant of the first user click
  {
    startTime = millis();
    println("time started!");
  }
  if (mouseOnLogo()) {
    mouseDrag = true;
  }
}

void mouseReleased()
{
  mouseDrag = false;
}

public boolean mouseOnLogo() {
    boolean closeDist = dist(mouseX, mouseY, logoX, logoY) < logoZ/1.7; //has to be

    //boolean closeDist = dist(mouseX, mouseY, logoX, logoY) < inchToPix(.3f); //has to be within +-0.05"
    //TODO: adjust this according to size of grid
    //boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"
    return closeDist;
}

//probably shouldn't modify this, but email me if you want to for some good reason.
public boolean checkForSuccess()
{
  Destination d = destinations.get(trialIndex);	
  boolean closeDist = dist(d.x, d.y, logoX, logoY)<inchToPix(.05f); //has to be within +-0.05"
  boolean closeRotation = calculateDifferenceBetweenAngles(d.rotation, logoRotation)<=5;
  boolean closeZ = abs(d.z - logoZ)<inchToPix(.1f); //has to be within +-0.1"	

  println("Close Enough Distance: " + closeDist + " (logo X/Y = " + d.x + "/" + d.y + ", destination X/Y = " + logoX + "/" + logoY +")");
  println("Close Enough Rotation: " + closeRotation + " (rot dist="+calculateDifferenceBetweenAngles(d.rotation, logoRotation)+")");
  println("Close Enough Z: " +  closeZ + " (logo Z = " + d.z + ", destination Z = " + logoZ +")mouseOnLogo");
  println("Close enough all: " + (closeDist && closeRotation && closeZ));

  return closeDist && closeRotation && closeZ;
}

//utility function I include to calc diference between two angles
double calculateDifferenceBetweenAngles(float a1, float a2)
{
  double diff=abs(a1-a2);
  diff%=90;
  if (diff>45)
    return 90-diff;
  else
    return diff;
}

//utility function to convert inches into pixels based on screen PPI
float inchToPix(float inch)
{
  return inch*screenPPI;
}
