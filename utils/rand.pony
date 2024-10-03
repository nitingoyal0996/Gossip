// bring the logic of picking up a random number from the member.pony file to this file
use "random"
use "time"

class RandomUtils
    let rand: Rand
    let random_fraction: F64

    new create() =>
        rand = Rand(Time.nanos().u64())
        random_fraction = rand.real()
    
    // Generates a random number in the range [min, max)
    fun get_random_number_in_range(min: USize, max: USize): USize =>
        if min >= max then
            // todo: throw an error
            return min  
        end
        
        // Scale the random fraction to the desired range
        let range_size = (max - min).u64()
        let scaled_value = (random_fraction * (range_size.f64() * 1.0)).round().usize()

        // Return the random number in the range [min, max)
        min + scaled_value

    // function to pick a number from 0 to 10
    fun get_random_number_from_0_to_10(): USize =>
        get_random_number_in_range(0, 10)
