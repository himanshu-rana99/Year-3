//"I pledge my honor that I have abided by the Stevens Honor System" - hrana2

//Runnable is implemented 
public class Swapper implements Runnable {
    private int offset;
    private Interval interval;
    private String content;
    private char[] buffer;

    public Swapper(Interval interval, String content, char[] buffer, int offset) {
        this.offset = offset;
        this.interval = interval;
        this.content = content;
        this.buffer = buffer;
    }

    @Override
    public void run() {
        // TODO: Implement me!
    	
    	//converts the content into an array of char 
    	char[] contentArr = content.toCharArray();
    	
    	//calculates the length of the interval using methods from the Interval class
    	int length = interval.getY() - interval.getX() + 1;
        for(int i = 0; i < length; i++){
            buffer[i + offset] = contentArr[i + interval.getX()];
        }
    }
}