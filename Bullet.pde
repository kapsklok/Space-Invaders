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
  
  void move() {
    xpos += xspeed;
    ypos += yspeed;
  }
  
  /**
    *Calculates if the projectile is off screen or hits the floor
    *
    */
  boolean isOffScreen() {
    boolean offX = xpos > width || xpos < 0;
    boolean offY = ypos > height - conf.FLOOR_HEIGHT || ypos < 0;
    
    return offX || offY;
  }
  
  /**
    * Display the projectile
    */
  void show() {
    stroke(conf.BULLET_COLOR);
    noFill();
    line(xpos + xspeed, ypos + yspeed, xpos, ypos);
  }
  
}