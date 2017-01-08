import java.util.Scanner;
import java.io.File;

class Config {
  
  // Window settings
    int DISP_WIDTH;
    int DISP_HEIGHT;
    color BACKGROUND_COLOR;
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
    color BULLET_COLOR;
    
    
    // Bomb settings
    int BOMB_BASE_SPEED;
    int BOMB_DAMAGE;
    color BOMB_COLOR;
    
    
    // Baddie settings
    float BADDIE_SHOOT_CHANCE;
    
    color BADDIE_PRIMARY_COLOR;
    color BADDIE_ALT_COLOR;
    
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
      BADDIE_SHOOT_CHANCE = 1.0 / (FRAMERATE * 4);
      
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
      BACKGROUND_COLOR = #111111;//#87CEFA;
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
      BULLET_COLOR = #FF0000;
      
      
      // Bomb settings
      BOMB_BASE_SPEED = 5;
      BOMB_DAMAGE = 30;
      BOMB_COLOR = #0000FF;
      
      
      // Baddie settings
      BADDIE_SHOOT_CHANCE = 1.0 / (FRAMERATE * 4);
      
      BADDIE_PRIMARY_COLOR = #FF0000;
      BADDIE_ALT_COLOR = #11FF00;
      
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