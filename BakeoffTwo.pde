import java.util.Arrays;
import java.util.Collections;
import java.util.Random;

String[] phrases; //contains all of the phrases
int totalTrialNum = 2; //the total number of phrases to be tested!
int currTrialNum = 0; // the current trial number (indexes into trials array above)
float startTime = 0; // time starts when the first letter is entered
float finishTime = 0; // records the time of when the final trial ends
float lastTime = 0; //the timestamp of when the last trial was completed
float lettersEnteredTotal = 0; //a running total of the number of letters the user has entered (need this for final WPM computation)
float lettersExpectedTotal = 0; //a running total of the number of letters expected (correct phrases)
float errorsTotal = 0; //a running total of the number of errors (when hitting next)
String currentPhrase = ""; //the current target phrase
String currentTyped = ""; //what the user has typed so far
final int DPIofYourDeviceScreen = 142; //you will need to look up the DPI or PPI of your device to make sure you get the right scale!!
//http://en.wikipedia.org/wiki/List_of_displays_by_pixel_density
final float sizeOfInputArea = DPIofYourDeviceScreen*1; //aka, 1.0 inches square!
PImage watch;
String currentKey = "";
boolean anyButtonPressed= (currentKey!="");

//Variables for my silly implementation. You can delete this:
char currentLetter = 'a';

PrintWriter output;
Table table;
String user_id = "1";
String fileName;

//You can modify anything in here. This is just a basic implementation.
void setup()
{
  watch = loadImage("watchhand3smaller.png");
  phrases = loadStrings("phrases2.txt"); //load the phrase set into memory
  Collections.shuffle(Arrays.asList(phrases), new Random()); //randomize the order of the phrases with no seed
  //Collections.shuffle(Arrays.asList(phrases), new Random(100)); //randomize the order of the phrases with seed 100; same order every time, useful for testing
 
  orientation(LANDSCAPE); //can also be PORTRAIT - sets orientation on android device
  size(800, 800); //Sets the size of the app. You should modify this to your device's native size. Many phones today are 1080 wide by 1920 tall.
  textFont(createFont("Arial", 24)); //set the font to arial 24. Creating fonts is expensive, so make difference sizes once in setup, not draw
  noStroke(); //my code doesn't use any strokes

  // define csv schema; code taken from DHCS slack by Dhruti Kuchibhotla
  fileName = "v2_performance_" + str(hour()) + "_" + str(minute()) + "_" + str(second()) + ".csv";
  output = createWriter(fileName);
  table = new Table();
  table.addColumn("user_ID", Table.STRING);
  table.addColumn("cycle_number", Table.INT);
  table.addColumn("Total time taken", Table.FLOAT);
  table.addColumn("Total letters entered", Table.FLOAT);
  table.addColumn("Total letters expected", Table.FLOAT);
  table.addColumn("Total errors entered", Table.FLOAT);
  table.addColumn("Raw WPM", Table.FLOAT);
  table.addColumn("Freebie errors", Table.FLOAT);
  table.addColumn("Penalty", Table.FLOAT);
  table.addColumn("WPM w/ penalty", Table.FLOAT);
}

//You can modify anything in here. This is just a basic implementation.
void draw()
{
  background(255); //clear background
  drawWatch(); //draw watch background
  fill(100);
  rect(width/2-sizeOfInputArea/2, height/2-sizeOfInputArea/2, sizeOfInputArea, sizeOfInputArea); //input area should be 1" by 1"

  if (finishTime!=0)
  {
    fill(128);
    textAlign(CENTER);
    text("Finished", 280, 150);
    return;
  }

  if (startTime==0 & !mousePressed)
  {
    fill(128);
    textAlign(CENTER);
    text("Click to start time!", 280, 150); //display this messsage until the user clicks!
  }

  if (startTime==0 & mousePressed)
  {
    nextTrial(); //start the trials!
  }

  if (startTime!=0)
  {
    //feel free to change the size and position of the target/entered phrases and next button 
    textAlign(LEFT); //align the text left
    fill(128);
    text("Phrase " + (currTrialNum+1) + " of " + totalTrialNum, 70, 50); //draw the trial count
    fill(128);
    text("Target:   " + currentPhrase, 70, 100); //draw the target string
    text("Entered:  " + currentTyped +"|", 70, 140); //draw what the user has entered thus far 

    //draw very basic next button
    fill(255, 0, 0);
    rect(600, 600, 200, 200); //draw next button
    fill(255);
    text("NEXT > ", 650, 650); //draw next label

    drawButtons();
    textAlign(CENTER);
    fill(200);
    text("" + currentLetter, width/2, height/2-sizeOfInputArea * 2 / 5); //draw current letter
  }
}

void drawButtons() {
  textAlign(CENTER);

  // the keyboard + display area is basically a 5 (row) * 3 (col) grid
  // |display area|  <- |
  // | jkl | abc  | def |
  // | ghi |  __  | mno |
  // |pqrs | tuv  | wxyz|

  float w = sizeOfInputArea / 3;
  float h = sizeOfInputArea / 4;
  text("←",  width / 2 + 1 * w ,  height / 2 - 1.2 * h);

  // draw letter keys
  fill(100);
  stroke(255, 0, 0);
  String[] keys = {"jkl", "abc", "def", "ghi", "_", "mno", "pqrs", "tuv", "wxyz"};
  for (int i = 0; i < keys.length; i++) {
    // calculate top-left corner coordinates
    float x = width / 2 - 1.5 * w + (i % 3) * w;
    float y = height / 2 - 1 * h + (i / 3) * h;
    // draw key background
    fill(0, 150, 150);
    rect(x, y, w, h);

    // draw letters
    fill(0, 255, 0);
  
    //text(keys[i], x + w / 2, y + h / 2);
    if (currentKey==keys[i] && keys[i].length()==3){
      for (int j=0; j < keys[i].length(); j++){
       
        textSize(25);
        fill(0, 408, 612, 816);   
        text(keys[i].charAt(j), x+w/2 + (j-keys[i].length()/2)*20 , y + h / 2);
        textSize(24); // revert to default global text size
        //draw button arond it
        //fill(0, 150, 150);
        //rect(x+w/2 + (j-keys[i].length()/2)*30, y + h / 2 -h/3, 30, 30);
      }
    } else if (currentKey==keys[i] && keys[i].length()==4){
      for (int j=0; j < keys[i].length(); j++){
         
          textSize(22);
          fill(0, 408, 612, 816);   
          text(keys[i].charAt(j), x+w/2 + (j-keys[i].length()/2)*14+10 , y + h / 2);
          textSize(24); // revert to default global text size
          //draw button arond it
          //fill(0, 150, 150);
          //rect(x+w/2 + (j-keys[i].length()/2)*30, y + h / 2 -h/3, 30, 30);
        }
    
    }
    else{
      textSize(20);
      text(keys[i], x + w / 2, y + h / 2);
      textSize(24); // revert to default global text size
    }
  }

}

String[] getLetterKeys() {
  String[] keys = {"jkl", "abc", "def", "ghi", "_", "mno", "pqrs", "tuv", "wxyz"};
  return keys;
}

String getKeyByCoordinate(float x, float y) {
  String[] keys = getLetterKeys();
  
  float w = sizeOfInputArea / 3;
  float h = sizeOfInputArea / 5;

  // top-left or keyboard area
  float leftX = width / 2 - 1.5 * w;
  float topY = height / 2 - 1 * h;

  if (y - topY < 0 || x - leftX < 0) {
    return "INVALID"; // not within keyboard area 
  }

  // (row, col) relatively to top-left corner of "SPACE" key
  int row = int((y - topY) / h);
  int col = int((x - leftX) / w);

  if (0 <= row && row < 3 && 0 <= col && col < 3) {
    int idx = 3 * row + col;
    return keys[idx];
  } 

  return "INVALID";
}

char getLetterByCoordinate(String key, float x, float y) {

  float w = sizeOfInputArea / 3;
  float h = sizeOfInputArea / 4;

  // top-left or keyboard area
  float leftX = width / 2 - 1.5 * w;
  float topY = height / 2 - 1 * h;

  //if (y - topY < 0 || x - leftX < 0) {
  //  return "INVALID"; // not within keyboard area 
  //}

  // (row, col) relatively to top-left corner of "SPACE" key
  int row = int((y - topY) / h);
  int col = int((x - leftX) / w);
  float num=(x-leftX-w*(col))/w;
  int idx=0;
  if (key == "pqrs" || key=="wxyz"){
    if (num<0.25){idx=0;} 
    else if (num>0.25 && num<=0.5){idx=1;}
    else if (num>0.5 && num<=0.75){idx=2; }
    else {idx=3;}}
  else{
  
    if (num<0.33333){
      idx=0;
    } else if (num>0.333333333 && num<0.6666666666){
      idx=1;
    }else{
      idx=2;
    }
  }
  System.out.println("detect col" + col);
  System.out.println("w:" +w+" x:"+x+ " leftX:"+leftX+" col:"+col+" num:"+num+"   idx:"+idx);
  //x+w/2 + (j-keys[i].length()/2)*30

  
   return key.charAt(idx);
  
}

void updateCurrentLetterAfterKeyPress(String key) {
  if (key == "_") {
    currentLetter = '_';
  }

  int idx = key.indexOf(currentLetter);
  if (idx == -1) {
    currentLetter = key.charAt(0);
  } else {
    int newIdx = (idx + 1) % key.length();
    currentLetter = key.charAt(newIdx);
  }
}

//my terrible implementation you can entirely replace
boolean didMouseClick(float x, float y, float w, float h) //simple function to do hit testing
{
  return (mouseX > x && mouseX<x+w && mouseY>y && mouseY<y+h); //check to see if it is in button bounds
}

void StringDelete(){
  if (currentTyped != ""){
    currentTyped=currentTyped.substring(0, currentTyped.length()-1);
  }
}
//my terrible implementation you can entirely replace
void mousePressed()
{
  if (mouseX>width / 2 + 0.5 * sizeOfInputArea / 3 && mouseX<width / 2 + 1.5 * sizeOfInputArea / 3 && mouseY > height / 2 - 2 * ( sizeOfInputArea / 4) && mouseY <height / 2 - 1 * ( sizeOfInputArea / 4) ){
    System.out.println("delete" );
    StringDelete();
  }
    
    
   
  
  String key = getKeyByCoordinate(mouseX, mouseY);
  // if the space key is pressed, enter a space immediately
  if (key == "_") {
    currentTyped += " ";
    currentLetter = ' ';
    currentKey = "_";
    return;
  }
  
  if (currentKey == key) {
    System.out.println("detect same key" + key);
    if (currentKey == "_") {
      System.out.println("in loop 1" );
      currentTyped += " ";
      currentLetter = ' ';
    }  else {
      currentLetter=getLetterByCoordinate(key, mouseX, mouseY);
      System.out.println("enter letter" + currentLetter);
      currentTyped += currentLetter;
      //currentLetter = ' ';
    }
  } else if (key == "INVALID") {
    // System.out.println("ERROR: invalid key coordinates " + mouseX + " " + mouseY);
  } else {
    // is a letter key
    currentKey=key;
    System.out.println("detect key" + key);
  }

  //You are allowed to have a next button outside the 1" area
  if (didMouseClick(600, 600, 200, 200)) //check if click is in next button
  {
    nextTrial(); //if so, advance to next trial
  }
}


void nextTrial()
{
  if (currTrialNum >= totalTrialNum) //check to see if experiment is done
    return; //if so, just return

  if (startTime!=0 && finishTime==0) //in the middle of trials
  {
    System.out.println("==================");
    System.out.println("Phrase " + (currTrialNum+1) + " of " + totalTrialNum); //output
    System.out.println("Target phrase: " + currentPhrase); //output
    System.out.println("Phrase length: " + currentPhrase.length()); //output
    System.out.println("User typed: " + currentTyped); //output
    System.out.println("User typed length: " + currentTyped.length()); //output
    System.out.println("Number of errors: " + computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim())); //trim whitespace and compute errors
    System.out.println("Time taken on this trial: " + (millis()-lastTime)); //output
    System.out.println("Time taken since beginning: " + (millis()-startTime)); //output
    System.out.println("==================");
    lettersExpectedTotal+=currentPhrase.trim().length();
    lettersEnteredTotal+=currentTyped.trim().length();
    errorsTotal+=computeLevenshteinDistance(currentTyped.trim(), currentPhrase.trim());
  }

  //probably shouldn't need to modify any of this output / penalty code.
  if (currTrialNum == totalTrialNum-1) //check to see if experiment just finished
  {
    finishTime = millis();
    System.out.println("==================");
    System.out.println("Trials complete!"); //output
    System.out.println("Total time taken: " + (finishTime - startTime)); //output
    System.out.println("Total letters entered: " + lettersEnteredTotal); //output
    System.out.println("Total letters expected: " + lettersExpectedTotal); //output
    System.out.println("Total errors entered: " + errorsTotal); //output

    float wpm = (lettersEnteredTotal/5.0f)/((finishTime - startTime)/60000f); //FYI - 60K is number of milliseconds in minute
    float freebieErrors = lettersExpectedTotal*.05; //no penalty if errors are under 5% of chars
    float penalty = max(errorsTotal-freebieErrors, 0) * .5f;
    
    System.out.println("Raw WPM: " + wpm); //output
    System.out.println("Freebie errors: " + freebieErrors); //output
    System.out.println("Penalty: " + penalty);
    System.out.println("WPM w/ penalty: " + (wpm-penalty)); //yes, minus, becuase higher WPM is better
    System.out.println("==================");

    // write to csv; code taken from DHCS slack by Dhruti Kuchibhotla
    TableRow row = table.addRow();
    row.setString("user_ID",user_id);
    row.setInt("cycle_number",currTrialNum);
    row.setFloat("Total time taken", (finishTime - startTime));
    row.setFloat("Total letters entered", lettersEnteredTotal);
    row.setFloat("Total letters expected", lettersExpectedTotal);
    row.setFloat("Total errors entered", errorsTotal);
    row.setFloat("Raw WPM", wpm);
    row.setFloat("Freebie errors", freebieErrors);
    row.setFloat("Penalty", penalty);
    row.setFloat("WPM w/ penalty", (wpm-penalty));
        
    saveTable(table, fileName);

    currTrialNum++; //increment by one so this mesage only appears once when all trials are done
    return;
  }

  if (startTime==0) //first trial starting now
  {
    System.out.println("Trials beginning! Starting timer..."); //output we're done
    startTime = millis(); //start the timer!
  } 
  else
    currTrialNum++; //increment trial number

  lastTime = millis(); //record the time of when this trial ended
  currentTyped = ""; //clear what is currently typed preparing for next trial
  currentPhrase = phrases[currTrialNum]; // load the next phrase!
  //currentPhrase = "abc"; // uncomment this to override the test phrase (useful for debugging)
}


void drawWatch()
{
  float watchscale = DPIofYourDeviceScreen/138.0;
  pushMatrix();
  translate(width/2, height/2);
  scale(watchscale);
  imageMode(CENTER);
  image(watch, 0, 0);
  popMatrix();
}





//=========SHOULD NOT NEED TO TOUCH THIS METHOD AT ALL!==============
int computeLevenshteinDistance(String phrase1, String phrase2) //this computers error between two strings
{
  int[][] distance = new int[phrase1.length() + 1][phrase2.length() + 1];

  for (int i = 0; i <= phrase1.length(); i++)
    distance[i][0] = i;
  for (int j = 1; j <= phrase2.length(); j++)
    distance[0][j] = j;

  for (int i = 1; i <= phrase1.length(); i++)
    for (int j = 1; j <= phrase2.length(); j++)
      distance[i][j] = min(min(distance[i - 1][j] + 1, distance[i][j - 1] + 1), distance[i - 1][j - 1] + ((phrase1.charAt(i - 1) == phrase2.charAt(j - 1)) ? 0 : 1));

  return distance[phrase1.length()][phrase2.length()];
}
