//"I pledge my honor that I have abided by the Stevens Honor System" - hrana2

package Assignment2;
import java.util.*;
import java.util.concurrent.*;

public class Gym implements Runnable {
	private static final int GYM_SIZE = 30;						
	private static final int GYM_REGISTERED_CLIENTS = 10000;	 
	
	private Map<WeightPlateSize,Integer> noOfWeightPlates;
	@SuppressWarnings("unused")
	private Set<Integer> clients;
	@SuppressWarnings("unused")
	private ExecutorService executor;
	
	public static Map<ApparatusType, Semaphore> mapSemaphore;
	public static Map<WeightPlateSize, Semaphore> currWeights;

	public Gym() {
		clients = new HashSet<Integer>();

		noOfWeightPlates = new HashMap<WeightPlateSize,Integer>();
		this.noOfWeightPlates.put(WeightPlateSize.values()[0],110);
		this.noOfWeightPlates.put(WeightPlateSize.values()[1],90);
		this.noOfWeightPlates.put(WeightPlateSize.values()[2],75);

		//A semaphore for each of the machines  
		Semaphore LEGPRESSMACHINE = new Semaphore(5);
		Semaphore BARBELL = new Semaphore(5);
		Semaphore HACKSQUATMACHINE = new Semaphore(5);
		Semaphore LEGEXTENSIONMACHINE = new Semaphore(5);
		Semaphore LEGCURLMACHINE = new Semaphore(5);
		Semaphore LATPULLDOWNMACHINE = new Semaphore(5);
		Semaphore PECDECKMACHINE = new Semaphore(5);
		Semaphore CABLECROSSOVERMACHINE = new Semaphore(5);

		//A semaphore for each of the different types of plates and the 
		//corresponding amounts that are available in total 
		Semaphore SMALL_3KG	= new Semaphore(110);
		Semaphore MEDIUM_5KG = new Semaphore(90);
		Semaphore LARGE_10KG = new Semaphore(75);

		//creating a hash map and setting each of the machines to an index
		mapSemaphore = new HashMap<ApparatusType, Semaphore>();
		mapSemaphore.put(ApparatusType.values()[0],LEGPRESSMACHINE);
		mapSemaphore.put(ApparatusType.values()[1],BARBELL);
		mapSemaphore.put(ApparatusType.values()[2],HACKSQUATMACHINE);
		mapSemaphore.put(ApparatusType.values()[3],LEGEXTENSIONMACHINE);
		mapSemaphore.put(ApparatusType.values()[4],LEGCURLMACHINE);
		mapSemaphore.put(ApparatusType.values()[5],LATPULLDOWNMACHINE);
		mapSemaphore.put(ApparatusType.values()[6],PECDECKMACHINE);
		mapSemaphore.put(ApparatusType.values()[7],CABLECROSSOVERMACHINE);

		//doing the same thing as the machines, except for the plate sizes 
		currWeights = new HashMap<WeightPlateSize, Semaphore>();
		currWeights.put(WeightPlateSize.values()[0],SMALL_3KG);
		currWeights.put(WeightPlateSize.values()[1],MEDIUM_5KG);
		currWeights.put(WeightPlateSize.values()[2],LARGE_10KG);
	}

	public void run() {	

		//using ExecutorService to handle executing multiple tasks
		//creates a thread pool with a fixed number of threads in a queue
		ExecutorService executor = Executors.newFixedThreadPool(GYM_SIZE);

		//creating new clients to use the gym 
		for(int x = 0; x < GYM_REGISTERED_CLIENTS; x++){
			Client newUser = new Client(x);
			newUser = newUser.generateRandom(x);
			executor.execute(newUser);
		}
		executor.shutdown();
	}
}