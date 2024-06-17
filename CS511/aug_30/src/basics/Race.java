package basics;

public class Race {
	public static class Shared implements Runnable {		
		private static int x=0;
		private int id;
		
		// Constructor
		Shared(int id) {
			this.id=id;
		}		
		public void run() {
			x=x+1;
		}
	}
	
	public static void main(String[] args)  {
		Thread t1 = new Thread(new Shared(0));
		Thread t2 = new Thread(new Shared(1));
		
		t1.start();
		t2.start();
		try {
			t1.join();
			t2.join();
		} catch (InterruptedException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		System.out.println(Shared.x);
		
	}

}
