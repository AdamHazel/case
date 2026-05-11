namespace Case.Race;

public class Contestant
{
    public Contestant(Car car, Driver driver)
    {
        Car = car;
        Driver = driver;
    }

    public Car Car { get; }

    public Driver Driver { get; }
}
