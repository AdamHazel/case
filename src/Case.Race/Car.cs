namespace Case.Race;

public class Car
{
    public Car(string brand, int topSpeed, int handelingLevel)
    {
        Brand = brand;
        TopSpeed = topSpeed;
        HandelingLevel = handelingLevel;
    }

    public string Brand { get; }

    public decimal TopSpeed { get; }

    public decimal HandelingLevel { get; }
}
