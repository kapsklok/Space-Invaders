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

void settings() {
  conf = new Config();
  scores = new Score(10, ';', "InvadersScores.txt");
  playerName = "Player";
  initialized = false;
  size(conf.DISP_WIDTH, conf.DISP_HEIGHT, P2D);
}

void setup() {
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
void draw() {
  
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
    text(playerName + "_", width / 2 - 80, (height - floorHeight) / 2 + 45);
    showFramerate();
    return;
  }
  
  processWorld();
  processBullets();
  processBaddies();
  
  player.showHUD(wave, baddiesOnScreen);
  showFramerate();
}

void processWorld() {
  
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

void processBullets() {
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

void processBaddies() {
  // calculate whther/where to move baddies
  int baddiesToMove[] = calculateBaddiesMove();
  
  for (int i = 0; i < baddies.size(); i++) {
    Player b = baddies.get(i);
        
    if (b.isPlayer) {
      //Player
      if (player.xpos < player.hitboxWidth / 2 - 1) {
        player.setMove(0, 0);
        player.xpos = player.hitboxWidth / 2;
        player.hitboxX = player.xpos - player.hitboxWidth / 2;
      } else if (player.xpos > width - (player.hitboxWidth / 2) + 1) {
        player.setMove(0, 0);
        player.xpos = width - player.hitboxWidth / 2;
        player.hitboxX = player.xpos - player.hitboxWidth / 2;

      }
      
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
int[] calculateBaddiesMove() {
  int[] baddiesToMove = new int[2];
  
  // If it is time to move
  if (framesSinceBaddieMove > conf.FRAMES_BETWEEN_BADDIE_MOVES - wave) {
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

void mouseClicked() {
  if (mouseButton == LEFT) {
    player.shoot(1);
  } else if (mouseButton == RIGHT) {
    player.shoot(2);
  }
}

void keyReleased() {
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

void keyPressed() {
  
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

void swapPlayers() {
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
void showFramerate() {
  //textSize(12);
  //fill(0);
  //int dispHeight = height - 5;
  //text(frameRate, width - 30, dispHeight);
  
  surface.setTitle("Space Invaders | " + playerName + " | " + int(frameRate) + " fps");
  
}

/**
  * Spawn default number of rows of baddies
  * 
  */

void spawnBaddies() {
  spawnBaddies(2);
}

/** 
  * Spawn configurable number of rows of baddies
  * 
  * @param layers  number of rows of baddies to create
  */

void spawnBaddies(int layers) {
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
      baddies.add(new Baddie(conf.BADDIES_MIN_X + conf.BADDIES_SPAWN_WIDTH * i, conf.BADDIES_MIN_Y + j * conf.BADDIES_SPAWN_HEIGHT));
      baddiesOnScreen++;
    }
  }
  // calculate time until end of wave based on current speed
  movesBeforeTurnaround = (int) floor((conf.DISP_WIDTH - conf.BADDIES_TOTAL_WIDTH) / (baddies.get(baddies.size() - 1).moveSpeed) - 1);
  
}

/**
  * Player is dead, remove all entities and display endgame 
  */
  
void dead() {
  scores.addScore(player.score, playerName);
  scores.writeScoresFile();
  
  baddies.clear();
  bullets.clear();
  
  gameOver = true;
}

/**
  * Draw the floor
  */
void drawFloor() {
  
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