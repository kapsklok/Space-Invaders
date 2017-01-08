import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.Scanner;

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
        this.writeScoresFile(SCORES_FILENAME);
    }
    
}