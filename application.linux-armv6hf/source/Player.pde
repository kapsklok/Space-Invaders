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
  
  color currentColor;
  color primaryColor;
  color altColor;
  
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
  void show() {
    image(currentImg, hitboxX, hitboxY);
  }
  
  /**
    * Display the player HUD
    * 
    * @param wave  current wave
    * @param baddiesLeft  number of baddies left on screen
    */
  void showHUD(int wave, int baddiesLeft) {
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
  
  void setMove(int x, int y) {
    xspeed = x * moveSpeed;
  }
  
  /**
    * Move the player to another player's position
    * @param p Target player
    */
  void setPos(Player p) {
    xpos = p.xpos;
    ypos = p.ypos;
    hitboxX = p.hitboxX;
    hitboxY = p.hitboxY;
    score = p.score;
  }
  
  void setImage(PImage i) {
    currentImg = i;
  }
  
  void move() {
    xpos += xspeed;
    ypos += yspeed;
    hitboxX += xspeed;
    hitboxY += yspeed;
  }
  
  void addScore(int s) {
    score += s;
  }
  
  boolean isDead() {
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
  void shoot(int projectile) {
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
  void createProjectile(int code, float angle) {
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
  boolean isCollidingWithBullet(Bullet b) {
    
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
  void tryShoot() {
    return;
  }
  
}