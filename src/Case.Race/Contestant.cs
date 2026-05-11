namespace Case.Race;

public class Contestant
{
    public Contestant(Vehicle vehicle, Driver driver)
    {
        Vehicle = vehicle;
        Driver = driver;
    }

    public Vehicle Vehicle { get; }

    public Driver Driver { get; }
}
