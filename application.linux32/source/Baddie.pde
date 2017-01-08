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
  boolean isCollidingWithBullet(Bullet b) {
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
  void tryShoot() {
    float shootRoll = random(0, 1);
        
    if (shootRoll <= shootChance) {
      // shoot in a random direction in the 90 degree range straight down
      createProjectile(1, random(5 * PI / 4, 7 * PI / 4));
    }
  }
  
  /**
    * Override Player shoot method to make sure the baddies don;t shoot at the mouse
    */
  void shoot() {}
  
}