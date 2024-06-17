//Himanshu Rana - hrana2
//"I pledge my honor that I have abided by the Stevens Honor System" - hrana2

import java.io.*;
import java.util.*;

public class TextSwap {

    private static String readFile(String filename) throws Exception {
        String line;
        StringBuilder buffer = new StringBuilder();
        File file = new File(filename);
        BufferedReader br = new BufferedReader(new FileReader(file));
        while ((line = br.readLine()) != null) {
            buffer.append(line);
        }
        br.close();
        return buffer.toString();
    }
    
    //This method returns an array of intervals. An interval is the start and end index of a chunk
    
    private static Interval[] getIntervals(int numChunks, int chunkSize) {
        // TODO: Implement me!
    	
    	 Interval[] setInterval = new Interval[numChunks];
         for(int i = 0; i < numChunks; i++) {
			/*
			 * (i * chunkSize) sets the starting of each interval and ((I + 1) * chunkSize) - 1) 
			 * is the end of the interval. We minus one because there is a space
			 * between each set of letters and we do not want the intervals to overlap. 
			 */        	 
        	 setInterval[i] = new Interval(i * chunkSize, ((i + 1) * chunkSize) - 1);
         }
         return setInterval;
    	
    	
    }

    private static List<Character> getLabels(int numChunks) {
        Scanner scanner = new Scanner(System.in);
        List<Character> labels = new ArrayList<Character>();
        int endChar = numChunks == 0 ? 'a' : 'a' + numChunks - 1;
        System.out.printf("Input %d character(s) (\'%c\' - \'%c\') for the pattern.\n", numChunks, 'a', endChar);
        for (int i = 0; i < numChunks; i++) {
            labels.add(scanner.next().charAt(0));
        }
        scanner.close();
        // System.out.println(labels);
        return labels;
    }
    
    //This method runs the Swapper threads and returns the reordered buffer which will be written in a new file. 
    private static char[] runSwapper(String content, int chunkSize, int numChunks) {
        List<Character> labels = getLabels(numChunks);
        Interval[] intervals = getIntervals(numChunks, chunkSize);
        // TODO: Order the intervals properly, then run the Swapper instances.
        
        //creates a new buffer that will be used to store the reordered letters. 
        char[] reorderBuffer = new char[content.length()];
        Interval interval2;
        int offset;
        
        //creates an array of threads, where each thread is a set of the same letters. 
        Thread[] eachLetter = new Thread[numChunks];
        for(int i = 0; i < labels.size(); i++) {
        	
        	//I am minusing 97 because that is the ASCII value of 'a'
        	interval2 = intervals[(labels.get(i)) - 97];
            offset = (i * chunkSize);
            //creates a new thread for each of the letters in the text file
            eachLetter[i] = new Thread(new Swapper(interval2, content, reorderBuffer, offset));
            //starts each thread
            eachLetter[i].start();
        }
        
        for(int i = 0; i < numChunks; i++) {
            try { 
            //joins all the threads together 
            eachLetter[i].join();
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        }
        return reorderBuffer;
    }

    //writes the reordered letters to a new file called output.txt.
    private static void writeToFile(String contents, int chunkSize, int numChunks) throws Exception {
        char[] buff = runSwapper(contents, chunkSize, contents.length() / chunkSize);
        PrintWriter writer = new PrintWriter("output.txt", "UTF-8");
        writer.print(buff);
        writer.close();
    }
    
    
    public static void main(String[] args) {
    	//checks to see if the user inputs the right amount of arguments
    	//and if not an error message will be printed.
        if (args.length != 2) {
            System.out.println("Usage: java TextSwap <chunk size> <filename>");
            return;
        }
        String contents = "";
        //sets the chunkSize to the value the user gives
        int chunkSize = Integer.parseInt(args[0]);
        try {
            contents = readFile(args[1]);
            writeToFile(contents, chunkSize, contents.length() / chunkSize);
        } catch (Exception e) {
            System.out.println("Error with IO.");
            //System.out.print(e);
            return;
        }
    }
}