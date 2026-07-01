fn main() {
    {
        let espresso = String::from("Delicious");
        println!("{}", espresso); // • "Delicious"
    } // `espresso` goes out of scope here; Rust automatically drops
      // its value

    // println!("{}", espresso); // • Error! `espresso` doesn't
    // exist anymore
}