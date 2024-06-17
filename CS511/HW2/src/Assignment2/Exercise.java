//"I pledge my honor that I have abided by the Stevens Honor System" - hrana2

package Assignment2;
import java.util.*;

public class Exercise {
	private ApparatusType at;
	private Map<WeightPlateSize, Integer> weight;
	private int duration;

	public Exercise(ApparatusType at, Map<WeightPlateSize,Integer> weight, int duration){
		this.at = at;
		this.weight = weight;
		this.duration = duration;
	}

	public ApparatusType getApp() {
		return this.at;
	}
	
	public Map<WeightPlateSize, Integer> getWeight() {
		return this.weight;
	}

	public int getDuration() { 
		return duration;
	} 

	public static Exercise generateRandom() {
		Random x = new Random();

		ApparatusType randomMachine = ApparatusType.values()[x.nextInt(ApparatusType.values().length)];

		//creating each of the weights for use
		int smallWeight = x.nextInt(11);
		int mediumWeight = x.nextInt(11);
		int largeWeight = x.nextInt(11);

	
		while(smallWeight + mediumWeight + largeWeight == 0) {
			smallWeight = x.nextInt(11);
			mediumWeight = x.nextInt(11);
			largeWeight = x.nextInt(11);
		}

		Map<WeightPlateSize, Integer> allWeights = new HashMap<WeightPlateSize, Integer>();

		allWeights.put(WeightPlateSize.values()[0], smallWeight);
		allWeights.put(WeightPlateSize.values()[1], mediumWeight);
		allWeights.put(WeightPlateSize.values()[2], largeWeight);

		//how long exercise takes in milliseconds 
		int duration = x.nextInt(10) + 1; 

		Exercise exercise = new Exercise(randomMachine, allWeights, duration);
		return exercise;
	}
}
