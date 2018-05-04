import processing.serial.*;

ArrayList snake;     
int snackSize = 1, positionX = 0, positionY = 0, direction = 0, columns = 30, rows = 16, step = 50, score = 0, last_time, tempo, inByte;     
long lastStep = 0;  
boolean start = false, loose = false, Player_Sam = false, Player_Johann = false, Head_Johann = false, Head_Sam = false, burger = false, flag = true, launchpadFlag = true, reset = false;
Point pizzaPoint, beerPoint; 
PImage snackGame, sam, samHead, joSkin, johann, joHead, pizza, beer, background, slowfast, chooseCharacter, clickHere1, clickHere2, nomorepizza, tryAgain, scorePic, gameOver;
Serial myPort;

void setup() {
  size(1500, 800); // (colums + rows) * step 
  textAlign(CENTER);
  noStroke();
  positionX = columns/2; // We place the snake in the middle
  positionY = rows/2;
  snake = new ArrayList(); // We initialise the ArrayList
  snake.add(new Point(positionX, positionY)); // The first element
  pizzaPoint = new Point((int)random(columns - 2), (int)random(rows - 2)); // Pizza and beer are create
  beerPoint = new Point((int)random(columns - 2), (int)random(rows - 2));
  lastStep = millis();
  myPort = new Serial(this, Serial.list()[0], 19200);
}

void draw() {
  background(255,255,255);
  fill(0);
  rect(0, 0, 1500, step/2);
  rect(0, 0, step/2, 800);
  rect(1500 - step/2, 0, step/2, 800);
  rect(0, 800 - step/2, 1500, step/2);
  if (myPort.available() > 0) {
    while (myPort.available() > 0) {
      if ((positionX < 2) || (positionX > columns - 4) || (positionY < 2)||(positionY > rows - 4))  myPort.write(1);
      reset = true;
      inByte = myPort.read();
      if(start == false) {
        if(inByte == 'N') {
        launchpadFlag = true;
        }
        if(launchpadFlag) {
          if(inByte == 'L') johann();
          if(inByte == 'R') sam();
        }
      }
      else {
        if(inByte == 'R' && launchpadFlag) {
          chipPressed('R');
          launchpadFlag = false;
        }
        else if(inByte == 'L' && launchpadFlag) {
          chipPressed('L');
          launchpadFlag = false;
        }
        else if(inByte == 'N') launchpadFlag = true;
      }
    }
  }
  else if (reset) System.exit(0);
  if (loose == true) {
    gameOver = loadImage ("gameover.png");    
    tryAgain = loadImage ("tryagain.png");
    scorePic = loadImage ("score.png");
    nomorepizza = loadImage ("NoMorePizza.png");
    image(gameOver, width / 2 - 250, height / 4, 500, 300);
    image(nomorepizza, width / 2 - 250, height / 8, 500, 70);
    image(tryAgain, width/2 - 110, height / 2 + 290, 200, 50);
    image(scorePic, width/2 - 250, height / 2 + 150, 200, 70);
    fill(0);
    textSize(50);
    text(score, width / 2, height / 2 + 205);
    return;
  }
  if (start == false) {
    score = 0;
    snackGame = loadImage("Snackgame.png");
    chooseCharacter = loadImage("ChooseCharacter.png");
    johann = loadImage("Johann.png");
    sam = loadImage("Sam.png");
    slowfast = loadImage("SlowFast.png");
    clickHere1 = loadImage ("ClickHere.png");
    clickHere2 = loadImage ("ClickHere.png");
    image(snackGame, width / 2 - 400, height / 2 + 260, 800, 100);
    image(sam, width / 2 + 150, height / 4, 300, 1350 / 3);
    image(johann, width / 2 - 450, height / 4, 300, 1350 / 3);
    image(slowfast, width / 2 - 100, height / 3 + 100, 200, 200);
    image(chooseCharacter, width / 2 - 175, height / 10, 360, 100);
    image(clickHere1, width / 2 - 670, height / 4, 200, 70);
    image(clickHere2, width / 2 + 450, height / 4, 200, 70);
    update(mouseX, mouseY);
    return;
  }
  if (millis() > lastStep + tempo) { 
    if (direction == 0) positionY -= 1; // north
    if (direction == 1) positionX += 1; // east
    if (direction == 2) positionY += 1; // south
    if (direction == 3) positionX -= 1; // west
    if ((positionX < 0) || (positionX > columns - 2) || (positionY < 0)||(positionY > rows - 2)) {
      loose = true;
      snake.clear(); 
      Player_Johann = false;
      Player_Sam = false;
      positionX = columns / 2;
      positionY = rows / 2;
      snackSize = 1;  
    }
    for (int i = snake.size() - 1; i >= 0; i--) { 
      Point snakeElement = (Point) snake.get(i);
      if (snakeElement.touch(positionX, positionY)) { 
        loose = true;
        snake.clear(); 
        Player_Johann = false;
        Player_Sam = false;
        positionX = columns / 2;
        positionY = rows / 2;
        snackSize = 1; 
        break;
      }
    }
    if (pizzaPoint.touch(positionX, positionY)) {
      score ++;  
      snackSize ++; 
      tempo -=1; 
      pizzaPoint.x = (int) random(columns - 2);
      pizzaPoint.y = (int) random(rows - 2);
    }
    if (beerPoint.touch(positionX, positionY) && score != 0) {
      burger = false;
      score = score + 2;
      snackSize = snackSize + 2;
      tempo -= 5; 
      beerPoint.x = (int) random(-10);
      beerPoint.y = (int) random(-10);
    }
    Point head = new Point(positionX, positionY);
    snake.add(head);
    if (snake.size() > snackSize) snake.remove(0);
    lastStep = millis();
  }
  samHead = loadImage("Samhead.png");
  joHead = loadImage("Johead.png");
  joSkin = loadImage("JoSkin.png");
  pizza = loadImage("Pizza.png");
  beer = loadImage("beer.png");
  image(pizza, pizzaPoint.x * step + step / 2, pizzaPoint.y * step + step / 2, step, step);
  if(score % 3 == 0 && score != 0) {
    if (flag == true) {
      beerPoint.x = (int) random(columns - 2);
      beerPoint.y = (int) random(rows - 2);
      last_time = millis();
      flag = false;
    }
    if (time(last_time)) image(beer, beerPoint.x * step + step / 2, beerPoint.y * step + step / 2, step, step);
    else {
      beerPoint.x = (int) random(-10);
      beerPoint.y = (int) random(-10);
    }
  }
  else flag = true;
  Point point = (Point) snake.get(snake.size() - 1);
  if (Head_Johann == true) image(joHead, point.x * step + step / 2, point.y * step + step / 2, step, step);
  else if(Head_Sam == true) image(samHead, point.x * step + step / 2, point.y * step + step / 2, step, step);
  for (int i = snake.size()-2; i >= 0; i--) { 
    point = (Point) snake.get(i);
    if (Head_Johann == true) image(joSkin, point.x * step + step / 2, point.y * step + step / 2, step, step);
    else if(Head_Sam == true) rect(point.x * step + step / 2, point.y * step + step / 2, step, step);
  } 
  fill(0);
  textSize(40);
  text(score, width/2, height - 100/3);
}
  
boolean time(int last_time){
 if (last_time + 5000 > millis()) return true;
 else return false;
}

void chipPressed(char commande) {
  if(loose == true) start = false;
  loose = false;
  if(commande == 'L') {
     if (direction == 0) direction = 3;
     else if (direction == 3) direction = 2;
     else if (direction == 2) direction = 3;
     else if (direction == 1) direction = 0;
  }
  if(commande == 'R') {
     if (direction == 0) direction = 1;
     else if (direction == 3) direction = 0;
     else if (direction == 1) direction = 2;
     else if (direction == 2) direction = 1;
  }
}

void keyPressed() {
  switch(keyCode) {
    case RIGHT:
      if (direction!=3) direction=1;
    break;
    case LEFT:
      if (direction!=1) direction=3;
    break;
    case UP:
      if (direction!=2) direction=0;
    break;
    case DOWN:
      if (direction!=0) direction=2;
    break;
  }
}

void mousePressed() {
  if(loose == true) start = false;
  loose = false;
  if (Player_Johann) {
    johann();
    Player_Johann = false;
  }
  if (Player_Sam) {
    sam();
    Player_Sam = false;
  }
}

void update(int x, int y) {
  if (overRect2(width/2 - 670, height/4, 200, 70)) {
    Player_Johann = true;
    Player_Sam = false;
  } 
  else if (overRect(width/2 + 450, height/4, 200, 70)) {
    Player_Sam = true;
    Player_Johann = false;
  }
  else {
    Player_Johann = Player_Sam = false;
  }
}

void johann() {
  Head_Johann = true;
  Head_Sam = false;
  tempo = 100;
  start = true;
}

void sam() {
  Head_Sam = true;
  Head_Johann = false;
  tempo = 200;
  start = true;
}

boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height)  return true;
  else return false;
}

boolean overRect2(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x + width && mouseY >= y && mouseY <= y + height) return true;
  else return false;
}

class Point {
  int x;
  int y;
  
  Point(int _x, int _y) {
    x = _x;
    y = _y;
  }
  
  Boolean touch(int _x, int _y) { return ((_x==x)&&(_y==y)); }
}    