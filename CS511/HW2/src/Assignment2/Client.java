//"I pledge my honor that I have abided by the Stevens Honor System" - hrana2

package Assignment2;
import java.util.*;
import java.util.concurrent.*;



public class Client implements Runnable {
	private int id;
	private List<Exercise> routine;
	
	public static Semaphore mutex = new Semaphore(1);

	public Client(int id) {
		this.id = id;
		routine = new ArrayList<Exercise>();
	}
	
	public List<Exercise> getRoutine() { 
		return this.routine;
	}

	public void addExercise(Exercise e) {
		this.routine.add(e);
	}

	
	public static Client generateRandom(int id) {
		Random num = new Random();
		//int num_exercises = ;
		//List<Exercise> client_routine = new ArrayList<>();

		Client user = new Client(id);
		for(int x = 0; x < (15 + num.nextInt(5)); x++) {
			Exercise eachExercise = new Exercise(null, null, 1); 
			eachExercise = eachExercise.generateRandom();		 
			user.addExercise(eachExercise);
		}
		return user;
	}

	public void run() {
		//prints out that the client has entered gym
		System.out.println("Client " + this.id + " has entered the gym.");

		//This for loop grabs the machine and weights based on the client's routine 
		for(Exercise exercise : this.getRoutine()) {
			//this is in a try - catch to prevent from any loss of threads 
			try {
				//grabbing apparatus 
				Gym.mapSemaphore.get((exercise.getApp())).acquire();

				//using a mutex so that once a weight is being used no one else can use it 
				mutex.acquire();

				//grabbing all the different weights that will be used  
				for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[0]).acquire();
				}
								
				for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[1]).acquire();
				}				
				
				for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[2]).acquire();
				}
				
				mutex.release();


				//printing out what weights each person used during their routine exercise 
				System.out.println("Client " + this.id + " is working on " + exercise.getApp() + " with " + 
						exercise.getWeight().get(WeightPlateSize.values()[0]) + " small weights, " + 
						exercise.getWeight().get(WeightPlateSize.values()[1]) + " medium weights, and " + 
						exercise.getWeight().get(WeightPlateSize.values()[2]) +" large weights for " + 
						exercise.getDuration() + " milliseconds.");
				Thread.sleep(exercise.getDuration());
            	
				
            	Gym.mapSemaphore.get((exercise.getApp())).release();

            	//giving back each of the weights that were being used so others can use them
	            for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[0]).release();
				}

	            for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[1]).release();
				}

	            for(int x = 0; x < exercise.getWeight().get(WeightPlateSize.values()[0]); x++) {
					Gym.currWeights.get(WeightPlateSize.values()[2]).release();
				}

			} catch (InterruptedException e) { 
                e.getStackTrace();
            }
			Gym.mapSemaphore.get((exercise.getApp())).release();


		}
		System.out.println("Client " + this.id + " exited gym.");
		return;
	}

}
