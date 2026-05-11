using Case.Race;

internal class Program
{
    private static void Main(string[] args)
    {
        var contestants = CreateDummyContestants();
        var races = new List<Race>
        {
            new Race("Oslobanen", contestants, 10),
            new Race("Bergensbanen", contestants, 7),
        };
        foreach (var race in races)
          race.Start();
    }

    private static Contestant[] CreateDummyContestants()
    {
        return new Contestant[]
        {
            new Contestant(new Car("Volvo", 120, 10), new Driver("Ola", 5)),
            new Contestant(new Car("BMW", 170, 13), new Driver("Truls", 10)),
            new Contestant(new Car("Nissan", 110, 7), new Driver("Leon", 5)),
            new Contestant(new Car("Subaru", 120, 10), new Driver("Kim", 4)),
            new Contestant(new Car("Toyota", 120, 10), new Driver("Liam", 8)),
            new Contestant(new Car("Fiat", 120, 10), new Driver("Georg", 3)),
            new Contestant(new Car("Ferrari", 190, 18), new Driver("Sebastian", 7)),
        };
    }
}

