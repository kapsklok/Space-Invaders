import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.Scanner; 
import java.io.File; 
import java.io.File; 
import java.io.FileNotFoundException; 
import java.io.PrintWriter; 
import java.util.Scanner; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class SpaceInvaders extends PApplet {

Config conf;

float playerStartX;
float playerStartY;
float floorHeight;
PImage floorTexture;
Score scores;

// Keep track of 2 "players" to switch between, but only one can be "active" at any time
Player player;
Player player1;
Player player2;

String playerName;

// keep track of all projectiles and baddies (and players)
ArrayList<Bullet> bullets;
ArrayList<Bomb> bombs;
ArrayList<Player> baddies;

// used for timing baddie moves
int framesSinceBaddieMove;
// make sure baddies turn around before they go off screen
int movesSinceBaddieTurnaround;
// calculated number of moves it will take for each turn around
int movesBeforeTurnaround;
// keep track of number of times baddies have turned around for wave pacing and gameover condition
int timesTurnedAround;
// keep track of direction baddies are moving
int baddiesMoveDirection;


int baddiesOnScreen;
int wave;

boolean gameOver;
boolean initialized;

public void settings() {
  conf = new Config();
  scores = new Score(10, ';', "InvadersScores.txt");
  playerName = "Player";
  initialized = false;
  size(conf.DISP_WIDTH, conf.DISP_HEIGHT, P2D);
}

public void setup() {
  frameRate(conf.FRAMERATE);
  
  floorHeight = conf.FLOOR_HEIGHT;
  floorTexture = loadImage(conf.FLOOR_TEXTURE);
  
  textureMode(NORMAL);
  textureWrap(REPEAT);
  
  playerStartX = conf.PLAYER_START_X;
  playerStartY = conf.PLAYER_START_Y;
  
  // create 2 players, one off screen
  player1 = new Player(playerStartX, playerStartY);
  player2 = new Player(playerStartX, -200);
  player = player1;
  player2.setImage(player2.altImg);
  
  bullets = new ArrayList<Bullet>();
  bombs = new ArrayList<Bomb>();
  baddies = new ArrayList<Player>();
  
  baddies.add(player1);
  baddies.add(player2);
  
  framesSinceBaddieMove = 0;
  movesSinceBaddieTurnaround = 0;
  baddiesMoveDirection = 1;
  baddiesOnScreen = 0;
  wave = 0;
  timesTurnedAround = 0;
  gameOver = false;
  
}


/** 
  * Main game loop
  */
public void draw() {
  
  if (!initialized) {
    gameOver = true;
  }
  background(conf.BACKGROUND_COLOR);
  drawFloor();
  
  // if the game is done, keep showing score but no baddies or bullets
  if (gameOver) {
    player.showHUD(wave, baddiesOnScreen);
    textSize(20);
    if (initialized) { text("GAME OVER", width / 2 - 60, (height - floorHeight) / 2); }
    text("Enter your Name", width / 2 - 80, (height - floorHeight) / 2 + 25);
    showFramerate();
    return;
  }
  
  processWorld();
  processBullets();
  processBaddies();
  
  player.showHUD(wave, baddiesOnScreen);
  showFramerate();
}

public void processWorld() {
  
  // if wave is over
  if (timesTurnedAround > (height - floorHeight) / conf.BADDIES_SPAWN_HEIGHT) {
    if (baddiesOnScreen > 0) {
      // baddies made it, game over
      dead();
      return;
    } else {
      // next wave
      spawnBaddies();
    }
    
  }
  
  // if current player is dead, switch
  if (player.health <= 0) {
    swapPlayers();
  }
  // if Both are dead, game over
  if (player1.health <= 0 && player2.health <= 0) {
    dead();
    return;
  }
  
}

public void processBullets() {
  // move and display each bullet, removing it from the list if offscreen
  for (int i = 0; i < bullets.size(); i++) {
    Bullet b = bullets.get(i);
    b.move();
    b.show();
    if (b.isOffScreen()) {
      bullets.remove(b);
    }
  }
}

public void processBaddies() {
  // calculate whther/where to move baddies
  int baddiesToMove[] = calculateBaddiesMove();
  
  for (int i = 0; i < baddies.size(); i++) {
    Player b = baddies.get(i);
        
    if (b.isPlayer) {
      //Player
      
    } else {
      // Baddie
        b.xspeed = b.moveSpeed * baddiesToMove[0];
        b.yspeed = conf.BADDIES_SPAWN_HEIGHT * baddiesToMove[1];
     
    }
    
    b.move();
    b.tryShoot();
    b.show();
    
    //Bullet collision
    for (int j = 0; j < bullets.size(); j++) {
      // get next bullet
      Bullet bullet = bullets.get(j);
      // if current bullet and baddie are colliding
      if (b.isCollidingWithBullet(bullet)) {
        // remove the bullet
        bullets.remove(bullet);
        // if the baddie died
        if (b.isDead()) {
          //remove it
          baddies.remove(b);
          baddiesOnScreen--;
          // add score as long as it wasnt the player who died
          if (!b.isPlayer) {
            player.addScore(b.score);
          }
          // if the wave is cleared, give bonus
          if (baddiesOnScreen == 0) {
            player.addScore(wave * conf.SCORE_PER_WAVE);
          }
        }
        break;
      }
      
    }
  }
  
  framesSinceBaddieMove++;
  
}

 /**
   * Calculate how the baddies will move, if they do
   *
   * @return baddiesToMove[x] will be 0 if no move, and positive or negative 1 indicating direction
   *                      [0] is for x direction
   *                      [1] for y direction
   */
public int[] calculateBaddiesMove() {
  int[] baddiesToMove = new int[2];
  
  // If it is time to move
  if (framesSinceBaddieMove > conf.FRAMES_BETWEEN_BADDIE_MOVES) {
    //move and reset counter
    baddiesToMove[0] = baddiesMoveDirection;
    framesSinceBaddieMove = 0;
    
    //check if they need to turn around
    if (movesSinceBaddieTurnaround >= movesBeforeTurnaround) {
      //turn them around and reset counter
      baddiesMoveDirection *= -1;
      movesSinceBaddieTurnaround = 0;
      timesTurnedAround++;
      
      // Move them down
      baddiesToMove[1] = 1;
      
    } else {
      movesSinceBaddieTurnaround++;
    }
    
  }  
    
  return baddiesToMove;
}

public void mouseClicked() {
  if (mouseButton == LEFT) {
    player.shoot(1);
  } else if (mouseButton == RIGHT) {
    player.shoot(2);
  }
}

public void keyReleased() {
  if (key == CODED) {
    switch (keyCode) {
      case LEFT:
      case RIGHT:
        player.setMove(0, 0);
        break;
    }
  } else {
    switch (key) {
      case 's':
      case 'S':
        swapPlayers();
        break;
      case 'a':
      case 'A':
      case 'd':
      case 'D':
        player.setMove(0, 0);
        break;
      case ' ':
        player.shoot(2);
        break;
      case 'p':
      case 'P':
        spawnBaddies();
        break;
      case 'r':
      //case 'R':
      //  if (gameOver) {
      //    setup();
      //  }
        break;
      case 'q':
      case 'Q':
        exit();
    }
  }
}

public void keyPressed() {
  
  if (gameOver) {
    
    if (keyCode == BACKSPACE) {
      if (playerName.length() > 0) {
        playerName = playerName.substring(0, playerName.length()-1);
      }
    } else if (keyCode == DELETE) {
      playerName = "";
    } else if (keyCode == ENTER) {
      initialized = true;
      setup();
    } else if (keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT) {
      playerName = playerName + key;
    }
    
    return;
    
  }
  
  if (key == CODED) {
    switch (keyCode) {
      case LEFT:
        player.setMove(-1, 0);
        break;
      case RIGHT:
        player.setMove(1, 0);
        break;
    }
  } else {
    switch (key) {
      case 'a':
      case 'A':
        player.setMove(-1, 0);
        break;
      case 'd':
      case 'D':
        player.setMove(1, 0);
        break;
    }
  }
}

public void swapPlayers() {
  // check which player is currently being controlled
  if (player == player1) {
    // make sure the other player isnt dead already
    if (player2.health <= 0) {
      // if Both are dead, quit
      if (player1.health <= 0) {
        dead();
        return;
      }
      // exit because other is dead
      return;
    }
    
    // swap players, moving other off screen safe from bullets
    // move other pleyer here
    player2.setPos(player1);
    // move current player offscreen
    player1.ypos = -200;
    player1.hitboxY = -200;
    // give control of other player
    player = player2;
    
  } else {
    // do everything the same as above, but with reversed players
    if (player1.health <= 0) {
      if (player2.health <= 0) {
        dead();
        return;
      }
      return;
    }
      player1.setPos(player2);
      player2.ypos = -200;
      player2.hitboxY = -200;
      player = player1;
  }
  
  
}

/**
  * Displays framerate in bottom right corner
  *
  */
public void showFramerate() {
  //textSize(12);
  //fill(0);
  //int dispHeight = height - 5;
  //text(frameRate, width - 30, dispHeight);
  
  surface.setTitle("Space Invaders | " + playerName + " | " + PApplet.parseInt(frameRate) + " fps");
  
}

/**
  * Spawn default number of rows of baddies
  * 
  */

public void spawnBaddies() {
  spawnBaddies(2);
}

/** 
  * Spawn configurable number of rows of baddies
  * 
  * @param layers  number of rows of baddies to create
  */

public void spawnBaddies(int layers) {
  // reset counters for baddie movement 
  framesSinceBaddieMove = 0;
  movesSinceBaddieTurnaround = 0;
  baddiesMoveDirection = 1;
  //baddiesOnScreen = 0;
  timesTurnedAround = 0;
  
  wave++;
  
  // create rows of baddies
  for (int j = 0; j < layers; j++) {
    for (int i = 0; i < conf.BADDIES_PER_ROW; i++) {
      baddies.add(new Baddie(conf.BADDIES_MIN_X + conf.BADDIES_SPAWN_WIDTH * i, conf.BADDIES_MIN_Y + j * conf.BADDIES_SPAWN_HEIGHT, wave * 5));
      baddiesOnScreen++;
    }
  }
  // calculate time until end of wave based on current speed
  movesBeforeTurnaround = (int) floor((conf.DISP_WIDTH - conf.BADDIES_TOTAL_WIDTH) / baddies.get(baddies.size() - 1).moveSpeed);
  
}

/**
  * Player is dead, remove all entities and display endgame 
  */
  
public void dead() {
  scores.addScore(player.score, playerName);
  scores.writeScoresFile();
  
  baddies.clear();
  bullets.clear();
  
  gameOver = true;
}

/**
  * Draw the floor
  */
public void drawFloor() {
  
  //remove border
  stroke(0);
  
  beginShape();
  texture(floorTexture);
  
  vertex(0, height - floorHeight, 0, 0);
  vertex(width, height - floorHeight, width / floorTexture.width, 0);
  vertex(width, height, width / floorTexture.width, floorHeight / floorTexture.height);
  vertex(0, height, 0, floorHeight / floorTexture.height);

  endShape();
}
class Baddie extends Player {
  
  float shootChance;
  
  /** 
    * Alternate constructor to accomodate faster movement in later waves
    * 
    * 
    */
  public Baddie(float startx, float starty, float extraSpeed) {
    this(startx, starty);
    moveSpeed += extraSpeed;
  }
  
  public Baddie(float startx, float starty) {
    super(startx, starty);
    isPlayer = false;
    
    primaryImg = loadImage(conf.BADDIE_PRIMARY_IMAGE);
    altImg = loadImage(conf.BADDIE_ALT_IMAGE);
    currentImg = primaryImg;
    
    hitboxWidth = conf.BADDIE_HITBOX_WIDTH;
    hitboxHeight= conf.BADDIE_HITBOX_HEIGHT;
    
    health = conf.BADDIE_HEALTH;
    moveSpeed = conf.BADDIE_MOVE_SPEED;
    score = conf.BADDIE_SCORE;
    
    shootChance = conf.BADDIE_SHOOT_CHANCE;
  }
  
  /** 
    * calculate whether this baddie is colliding with a bullet
    * 
    * @param b  bullet to check collision with
    * @return   true if collision
    */
  public boolean isCollidingWithBullet(Bullet b) {
    boolean colliding = super.isCollidingWithBullet(b);
    
    // switch to low health image if below half health
    if (colliding) {
      if (health <= conf.BADDIE_HEALTH / 2) {
        currentImg = altImg;
      }
    }
    
    return colliding;
  }
  
  /**
    * Shoot only as often as the config says
    */
  public void tryShoot() {
    float shootRoll = random(0, 1);
        
    if (shootRoll <= shootChance) {
      // shoot in a random direction in the 90 degree range straight down
      createProjectile(1, random(5 * PI / 4, 7 * PI / 4));
    }
  }
  
  /**
    * Override Player shoot method to make sure the baddies don;t shoot at the mouse
    */
  public void shoot() {}
  
}
class Bomb extends Bullet {
  
  public Bomb(Player origin, double angle) {
    super(origin, angle);
    // override bullet stats with bomb stats
    baseSpeed = conf.BOMB_BASE_SPEED;
    damage = conf.BOMB_DAMAGE;
    xspeed = (float) Math.cos(angle) * baseSpeed;
    yspeed = (float) Math.sin(angle) * baseSpeed * -1;
    
    this.angle = angle;
  }
  
  public void show() {
    fill(conf.BOMB_COLOR);
    noStroke();
    ellipse(xpos, ypos, 5, 5);
  }
  
}
class Bullet {
  float baseSpeed;
  float damage;
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
  double angle;
  boolean playerBullet;
  
  /**
    * @param origin  player or baddie from which the projectile originates
    * @param angle   angle in RADIANS
    */
  public Bullet(Player origin, double angle) {
    baseSpeed = conf.BULLET_BASE_SPEED;
    damage = conf.BULLET_DAMAGE;

    xspeed = (float) Math.cos(angle) * baseSpeed;
    yspeed = (float) Math.sin(angle) * baseSpeed * -1;
    
    xpos = origin.xpos;
    ypos = origin.ypos;
    
    this.angle = angle;
    
    playerBullet = origin.isPlayer;
  }
  
  public void move() {
    xpos += xspeed;
    ypos += yspeed;
  }
  
  /**
    *Calculates if the projectile is off screen or hits the floor
    *
    */
  public boolean isOffScreen() {
    boolean offX = xpos > width || xpos < 0;
    boolean offY = ypos > height - conf.FLOOR_HEIGHT || ypos < 0;
    
    return offX || offY;
  }
  
  /**
    * Display the projectile
    */
  public void show() {
    stroke(conf.BULLET_COLOR);
    noFill();
    line(xpos + xspeed, ypos + yspeed, xpos, ypos);
  }
  
}



class Config {
  
  // Window settings
    int DISP_WIDTH;
    int DISP_HEIGHT;
    int BACKGROUND_COLOR;
    int FRAMERATE;
    
    
    // World Settings
    float FLOOR_HEIGHT;
    String FLOOR_TEXTURE;
    float PLAYER_START_X;
    float PLAYER_START_Y;
    int SCORE_PER_WAVE;
    
    
    // Player settings
    float PLAYER_MOVE_SPEED;
    
    int PLAYER_HEALTH;
    int PLAYER_AMMO;
    int PLAYER_BOMBS;
    
    String PLAYER_PRIMARY_IMAGE;
    String PLAYER_ALT_IMAGE;
    
    float PLAYER_HITBOX_WIDTH;
    float PLAYER_HITBOX_HEIGHT;
    
    int MAX_NAME_LENGTH;
    
    
    // Bullet settings
    int BULLET_BASE_SPEED;
    int BULLET_DAMAGE;
    int BULLET_COLOR;
    
    
    // Bomb settings
    int BOMB_BASE_SPEED;
    int BOMB_DAMAGE;
    int BOMB_COLOR;
    
    
    // Baddie settings
    float BADDIE_SHOOT_CHANCE;
    
    int BADDIE_PRIMARY_COLOR;
    int BADDIE_ALT_COLOR;
    
    String BADDIE_PRIMARY_IMAGE;
    String BADDIE_ALT_IMAGE;
    
    float BADDIE_HITBOX_WIDTH;
    float BADDIE_HITBOX_HEIGHT;
    float BADDIE_BOTTOM_HEIGHT;
    
    float BADDIE_MOVE_SPEED;
    int BADDIE_HEALTH;
    int BADDIE_SCORE;
    
    int BADDIES_PER_ROW;
    float BADDIES_SPAWN_WIDTH;
    float BADDIES_SPAWN_HEIGHT;
    
    float BADDIES_MIN_X;
    float BADDIES_MAX_X;
    float BADDIES_MIN_Y;
    
    float BADDIES_TOTAL_WIDTH;
    int MOVES_BEFORE_TURNAROUND;
    
    int FRAMES_BETWEEN_BADDIE_MOVES;
  
  public Config() {
    
    try {
      
      String[] lines = loadStrings("settings.txt");
      ArrayList<String> settingsList = new ArrayList<String>();
      
      for (String line : lines) {
        line = line.replaceAll("[^a-zA-Z=0-9/._]","");
        line = line.replaceAll("\\s","");
        String[] sp;
        if (!line.contains("//") && !line.equals("")) {
          sp = line.split("=");
          settingsList.add(sp[0]);
          settingsList.add(sp[1]);
          
        }
        
      }

      
      // Window settings
      DISP_WIDTH = Integer.parseInt( settingsList.get(indexInArrayList(settingsList, "DISP_WIDTH") + 1) );
      DISP_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "DISP_HEIGHT") + 1) );
      BACKGROUND_COLOR = unhex("FF" + settingsList.get( indexInArrayList(settingsList, "BACKGROUND_COLOR") + 1));
      FRAMERATE = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "FRAMERATE") + 1) );
      
      
      // World Settings
      FLOOR_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "FLOOR_HEIGHT") + 1) );
      FLOOR_TEXTURE = settingsList.get( indexInArrayList(settingsList, "FLOOR_TEXTURE") + 1);
      PLAYER_START_X = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_START_X") + 1) );
      PLAYER_START_Y = DISP_HEIGHT - FLOOR_HEIGHT;
      SCORE_PER_WAVE = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "SCORE_PER_WAVE") + 1) );
      
      
      // Player settings
      PLAYER_MOVE_SPEED = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_MOVE_SPEED") + 1) );
      
      PLAYER_HEALTH = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_HEALTH") + 1) );
      PLAYER_AMMO = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_AMMO") + 1) );
      PLAYER_BOMBS = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_BOMBS") + 1) );
      
      PLAYER_PRIMARY_IMAGE = settingsList.get( indexInArrayList(settingsList, "PLAYER_PRIMARY_IMAGE") + 1);
      PLAYER_ALT_IMAGE = settingsList.get( indexInArrayList(settingsList, "PLAYER_ALT_IMAGE") + 1);
      
      PLAYER_HITBOX_WIDTH = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_HITBOX_WIDTH") + 1) );
      PLAYER_HITBOX_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "PLAYER_HITBOX_HEIGHT") + 1) );
      
      MAX_NAME_LENGTH = Integer.parseInt(settingsList.get( indexInArrayList(settingsList, "MAX_NAME_LENGTH") +1) );
      
      // Bullet settings
      BULLET_BASE_SPEED = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BULLET_BASE_SPEED") + 1) );
      BULLET_DAMAGE = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BULLET_DAMAGE") + 1) );
      BULLET_COLOR = unhex("FF" +  settingsList.get( indexInArrayList(settingsList, "BULLET_COLOR") + 1) );
      
      
      // Bomb settings
      BOMB_BASE_SPEED = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BOMB_BASE_SPEED") + 1) );
      BOMB_DAMAGE = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BOMB_DAMAGE") + 1) );
      BOMB_COLOR = unhex("FF" +  settingsList.get( indexInArrayList(settingsList, "BOMB_COLOR") + 1) );
      
      
      // Baddie settings
      BADDIE_SHOOT_CHANCE = 1.0f / (FRAMERATE * 4);
      
      BADDIE_PRIMARY_IMAGE = settingsList.get( indexInArrayList(settingsList, "BADDIE_PRIMARY_IMAGE") + 1);
      BADDIE_ALT_IMAGE = settingsList.get( indexInArrayList(settingsList, "BADDIE_ALT_IMAGE") + 1);
      
      BADDIE_HITBOX_WIDTH = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIE_HITBOX_WIDTH") + 1) );
      BADDIE_HITBOX_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIE_HITBOX_HEIGHT") + 1) );
      BADDIE_BOTTOM_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIE_BOTTOM_HEIGHT") + 1) );
      
      BADDIE_MOVE_SPEED = BADDIE_HITBOX_WIDTH;
      BADDIE_HEALTH = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIE_HEALTH") + 1) );
      BADDIE_SCORE = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIE_SCORE") + 1) );
      
      BADDIES_PER_ROW = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIES_PER_ROW") + 1) );
      BADDIES_SPAWN_WIDTH = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIES_SPAWN_WIDTH") + 1) );
      BADDIES_SPAWN_HEIGHT = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIES_SPAWN_HEIGHT") + 1) );
      
      BADDIES_MIN_X = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIES_MIN_X") + 1) );
      BADDIES_MAX_X = DISP_WIDTH - BADDIES_MIN_X;
      BADDIES_MIN_Y = Integer.parseInt( settingsList.get( indexInArrayList(settingsList, "BADDIES_MIN_Y") + 1) );
      
      BADDIES_TOTAL_WIDTH = BADDIES_PER_ROW * BADDIES_SPAWN_WIDTH;
      MOVES_BEFORE_TURNAROUND = (int) floor((DISP_WIDTH - BADDIES_TOTAL_WIDTH) / BADDIE_MOVE_SPEED);
      
      FRAMES_BETWEEN_BADDIE_MOVES = FRAMERATE;
      
      } catch (Exception e) {
      // Error reading file, use default values
      System.out.println("Error reading Settings.txt file; using default settings");
      e.printStackTrace();
      
      // Window settings
      DISP_WIDTH = 700;
      DISP_HEIGHT = 500;
      BACKGROUND_COLOR = 0xff111111;//#87CEFA;
      FRAMERATE = 60;
      
      
      // World Settings
      FLOOR_HEIGHT = 60;
      FLOOR_TEXTURE = "Floor_Texture.png";
      PLAYER_START_X = 20;
      PLAYER_START_Y = DISP_HEIGHT - FLOOR_HEIGHT;
      SCORE_PER_WAVE = 200;
      
      
      // Player settings
      PLAYER_MOVE_SPEED = 3;
      
      PLAYER_HEALTH = 50;
      PLAYER_AMMO = 999;
      PLAYER_BOMBS = 10;
      
      PLAYER_PRIMARY_IMAGE = "Player_Ship_Main.png";
      PLAYER_ALT_IMAGE = "Player_Ship_Alt.png";
      
      PLAYER_HITBOX_WIDTH = 20;
      PLAYER_HITBOX_HEIGHT = 40;
      
      
      // Bullet settings
      BULLET_BASE_SPEED = 7;
      BULLET_DAMAGE = 10;
      BULLET_COLOR = 0xffFF0000;
      
      
      // Bomb settings
      BOMB_BASE_SPEED = 5;
      BOMB_DAMAGE = 30;
      BOMB_COLOR = 0xff0000FF;
      
      
      // Baddie settings
      BADDIE_SHOOT_CHANCE = 1.0f / (FRAMERATE * 4);
      
      BADDIE_PRIMARY_COLOR = 0xffFF0000;
      BADDIE_ALT_COLOR = 0xff11FF00;
      
      BADDIE_PRIMARY_IMAGE = "Baddie_Ship_Main.png";
      BADDIE_ALT_IMAGE = "Baddie_Ship_Alt.png";
      
      BADDIE_HITBOX_WIDTH = 40;
      BADDIE_HITBOX_HEIGHT = 40;
      BADDIE_BOTTOM_HEIGHT = 250;
      
      BADDIE_MOVE_SPEED = BADDIE_HITBOX_WIDTH;
      BADDIE_HEALTH = 30;
      BADDIE_SCORE = 10;
      
      BADDIES_PER_ROW = 7;
      BADDIES_SPAWN_WIDTH = 60;
      BADDIES_SPAWN_HEIGHT = 60;
      
      BADDIES_MIN_X = 20;
      BADDIES_MAX_X = DISP_WIDTH - BADDIES_MIN_X;
      BADDIES_MIN_Y = 50;
      
      BADDIES_TOTAL_WIDTH = BADDIES_PER_ROW * BADDIES_SPAWN_WIDTH;
      MOVES_BEFORE_TURNAROUND = (int) floor((DISP_WIDTH - BADDIES_TOTAL_WIDTH) / BADDIE_MOVE_SPEED);
      
      FRAMES_BETWEEN_BADDIE_MOVES = FRAMERATE;
    }
  }
  
  private int indexInArrayList(ArrayList<String> a, String search) {
    for (int i = 0; i < a.size(); i++) {
      if (a.get(i).equals(search)) {
        return i;
      }
    }
    return -2;
  }
  
}
class Player {
  float moveSpeed; 
  int health;
  int ammo;
  int bombs;
  int score;
  
  boolean isPlayer;
  
  float xpos;
  float ypos;
  float xspeed;
  float yspeed;
  
  float hitboxX;
  float hitboxY;
  float hitboxWidth;
  float hitboxHeight;
  
  int currentColor;
  int primaryColor;
  int altColor;
  
  PImage currentImg;
  PImage primaryImg;
  PImage altImg;
  
  public Player(float startx, float starty) {
    isPlayer = true;
    
    hitboxWidth = conf.PLAYER_HITBOX_WIDTH;
    hitboxHeight= conf.PLAYER_HITBOX_HEIGHT;
    
    xpos = startx;
    ypos = starty - hitboxHeight / 2;
    
    hitboxX = xpos - hitboxWidth / 2;
    hitboxY = ypos - hitboxHeight / 2;
    
    moveSpeed = conf.PLAYER_MOVE_SPEED;
    xspeed = 0;
    yspeed = 0;
    
    primaryImg = loadImage(conf.PLAYER_PRIMARY_IMAGE);
    altImg = loadImage(conf.PLAYER_ALT_IMAGE);
    currentImg = primaryImg;
    
    health = conf.PLAYER_HEALTH;
    ammo = conf.PLAYER_AMMO;
    bombs = conf.PLAYER_BOMBS;
  }
  
  /**
    * Display the player
    */
  public void show() {
    image(currentImg, hitboxX, hitboxY);
  }
  
  /**
    * Display the player HUD
    * 
    * @param wave  current wave
    * @param baddiesLeft  number of baddies left on screen
    */
  public void showHUD(int wave, int baddiesLeft) {
    textSize(12);
    fill(0);
    int dispHeight = height - 5;
    text("Health: " + health, 5, dispHeight);
    text("Bullets: " + ammo, 100, dispHeight);
    text("Bombs: " + bombs, 200, dispHeight);
    text("Score: " + score, 300, dispHeight);
    text("Wave: " + wave, 400, dispHeight);
    
    fill(200);
    if (baddiesLeft > 0) {
      text("Baddies: " + baddiesLeft, 5, 15);
    } else {
      text("Next wave: P", 5, 15);
    }
    
  }
  
  public void setMove(int x, int y) {
    xspeed = x * moveSpeed;
  }
  
  /**
    * Move the player to another player's position
    * @param p Target player
    */
  public void setPos(Player p) {
    xpos = p.xpos;
    ypos = p.ypos;
    hitboxX = p.hitboxX;
    hitboxY = p.hitboxY;
    score = p.score;
  }
  
  public void setImage(PImage i) {
    currentImg = i;
  }
  
  public void move() {
    xpos += xspeed;
    ypos += yspeed;
    hitboxX += xspeed;
    hitboxY += yspeed;
  }
  
  public void addScore(int s) {
    score += s;
  }
  
  public boolean isDead() {
    return health <= 0;
  }
  
  /**
    * Calculates the angle for a new projectile
    * 
    * @param projectile  Projectile code
    *  Projectile codes:
    *  1  bullet
    *  2  bomb
    */
  public void shoot(int projectile) {
    // calculate angle to create the projectile at
    // length of triangle in vertical direction
    float y = player.ypos - mouseY;
    // length of triangle in horizontal direction
    float x = mouseX - player.xpos;
    
    float angle;
    // avoid divide by zero on rare case that player mouse is directly above player
    if (x != 0) {
      angle = (float) Math.atan(y / x);
    } else {
      angle = PI / 2;
    }

    // if mouse is to left of player, angle should be pi radians lower
    if (x < 0) {
      angle -= PI;
    }
    
    // actually create the projectile with the computed angle
    createProjectile(projectile, angle);
  }
  
  /** 
    * Creates a projectile from the player
    * 
    *  Projectile codes:
    *  1  bullet
    *  2  bomb
    */
  public void createProjectile(int code, float angle) {
    Bullet created = null;
    
    switch(code) {
      case 1:
        if (ammo > 0) {
          created = new Bullet(this, angle);
          ammo -= 1;
        }
        break;
      case 2:
        if (bombs > 0) {
          created = new Bomb(this, angle);
          bombs -= 1;
        }
        break;
    }
    // only adda non-null object, in case an invalid code was passed
    if (created != null) {
      bullets.add(created);
    }
  }
  
  /**
    * Check if Player is colliding with a projectile
    * 
    * @param b  Bullet to check collision with
    */
  public boolean isCollidingWithBullet(Bullet b) {
    
    // dont allow a bullet to collide with the shooter
    if (b.playerBullet == isPlayer) {
      return false;
    }
    
    if (b.xpos >= this.xpos - hitboxWidth / 2 && b.xpos <= this.xpos + hitboxWidth / 2) {
      if (b.ypos >= this.ypos - hitboxHeight / 2 && b.ypos <= this.ypos + hitboxHeight / 2) {
        health -= b.damage;
        return true;
      }
    }
    return false;
    
  }
  
  /**
    * Method to be used by a Baddie in using chance to shoot
    */
  public void tryShoot() {
    return;
  }
  
}





public class Score {
    
    public final int NUM_HIGH_SCORES;
    public final char SCORE_SEPARATOR;
    public final String SCORES_FILENAME;
    
    private String[][] scores; // [[name1][score1]][[name2][score2]]
    
    public Score(int numHighScores, char scoreSeparator, String ScoresFilename) {
        NUM_HIGH_SCORES = numHighScores;
        SCORE_SEPARATOR = scoreSeparator;
        SCORES_FILENAME = ScoresFilename;
        
        this.scores = new String[NUM_HIGH_SCORES][2];
        this.loadScores();
    }
    
    /**
     * Sorts the scores list in descending order of points, keeping
     * the correct name with each score
     */
    private void sortScores() {
      
         boolean flag = true;   // set flag to true to begin first pass
         String[] temp;   //holding variable

         while ( flag )
         {
            flag= false;  //set flag to false awaiting a possible swap
            for( int j=0;  j < scores.length -1;  j++ )
            {
                 if ( Integer.parseInt(scores[j][1]) < Integer.parseInt(scores[j+1][1]) )   // change to > for ascending sort
                 {
                     temp = scores[ j ];        //swap elements
                     scores[ j ] = scores[ j+1 ];
                     scores[ j+1 ] = temp;
                    flag = true;        //shows a swap occurred  
                } 
            } 
        }
      
    }
    
    /**
     * Gets a name then adds the score with the given name
     * 
     */
    public boolean addScore(int score) {
      
      System.out.println("Congratulations, you made the high scores chart!");
      System.out.println("What is your name?");
      System.out.print("> ");
            
      Scanner in = new Scanner(System.in);
      String name = in.nextLine();
      in.close();
      
      return addScore(score, name);
      
    }
    
    /**
     * Checks whether or not the score is good enough to make it on the
     * list, and adds it if so
     * 
     * @param score player's achieved score
     * @return true if score made it on the list
     */
    public boolean addScore(int score, String name) {
        // remember if the new score makes the cut
        boolean scoreAdded = false;
        
        this.sortScores();
        
        // the minimum score to beat to be added to the list
        // initialize high to avoid replacing higher score
        int minScore = Integer.MAX_VALUE;
        try {
            // change minScore to the actual minimum score in the table
            minScore = Integer.parseInt(this.scores[NUM_HIGH_SCORES - 1][1]);
            
        } catch (NumberFormatException e) {
            // this should never happen
            System.out.println("Somehow the last score in the table was not an integer ???");
        }
        
        if (score > minScore) {
            scoreAdded = true;
            System.out.println("Score added");
            
            // replace the minimum score and then re-sort
            this.scores[NUM_HIGH_SCORES - 1][0] = name;
            this.scores[NUM_HIGH_SCORES - 1][1] = score + "";
            this.sortScores();
        }
        
        return scoreAdded;
    }
    
    /**
     * Loads scores from the designated file or if the file does not exist or
     * is not readable then generate an empty list
     */
    private void loadScores() {
        try {
            Scanner lines = new Scanner(new File(SCORES_FILENAME));
            int i = 0;
            while (lines.hasNextLine()) {
                String currLine = lines.nextLine();
                String[] scoreLine = currLine.split(SCORE_SEPARATOR + "");
                scores[i][0] = scoreLine[0];
                scores[i][1] = scoreLine[1];
                i++;
            }
            // fill out the rest of the scores if there were not enough
            // in the file to satisfy NUM_HIGH_SCORES
            for (;i < NUM_HIGH_SCORES; i++) {
                scores[i][0] = "Nobody";
                scores[i][1] = "0";
            }
            lines.close();
            sortScores();
        } catch (Exception e) {
            // TODO Auto-generated catch block
            // Scores file was not accessible, create empty table instead
            this.generateEmptyScoresTable();
            this.writeScoresFile();
        }
    }
    
    /**
     * Create an "empty" scores table, filling with Nobody's with lowering scores
     */
    private void generateEmptyScoresTable() {
        
        for (int i = 0; i < NUM_HIGH_SCORES; i++) {
            scores[i][0] = "Nobody";
            scores[i][1] = ( 500 / (i +1) ) + "";
        }
        
        this.writeScoresFile();
    }
    
    /**
     * Prints the current scores list in a pretty table
     */
    public void printScores() {
        System.out.println("---------High Scores---------");
        
        for (int i = 0; i < NUM_HIGH_SCORES; i++) {
            System.out.println((i+1)+ ". " + scores[i][1] + "\t\t" + scores[i][0]);
            //                   #. {score}    {name}
        }
    }
    
    /**
     * Writes current score table to the designated file
     * @param fileName name of file to write to
     */
    public void writeScoresFile(String fileName) {
        // make sure the scores are sorted
        this.sortScores();
        
        this.printScores();
        
        try {
            //PrintWriter writer = new PrintWriter(new File(fileName));
            PrintWriter writer = new PrintWriter(fileName);
            for (int i = 0; i < NUM_HIGH_SCORES; i++) {
                writer.print(scores[i][0] + SCORE_SEPARATOR + scores[i][1] + "\n");
            }
            writer.flush();
            writer.close();
        //} catch (FileNotFoundException e) {
        }catch (Exception e) {
            // TODO Auto-generated catch block
            System.out.println("Unable to print to file: " + fileName);
            e.printStackTrace();
        }
        
    }
    
    public void writeScoresFile() {
        this.writeScoresFile("data/" + SCORES_FILENAME);
    }
    
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "SpaceInvaders" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
