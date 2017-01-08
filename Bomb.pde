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
  
  void show() {
    fill(conf.BOMB_COLOR);
    noStroke();
    ellipse(xpos, ypos, 5, 5);
  }
  
}