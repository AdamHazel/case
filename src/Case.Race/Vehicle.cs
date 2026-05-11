namespace Case.Race;

public abstract class Vehicle
{
    public Vehicle(string brand, int topSpeed, int handelingLevel)
    {
        Brand = brand;
        TopSpeed = topSpeed;
        HandelingLevel = handelingLevel;
    }
    
    public string Brand { get; }

    public decimal TopSpeed { get; }

    public decimal HandelingLevel { get; }

    public abstract string TypeOfVehicle { get; set; }
}