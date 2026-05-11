namespace Case.Race;

public class Truck : Vehicle
{
    public Truck(string brand, int topSpeed, int handelingLevel) :
        base(brand, topSpeed, handelingLevel)
    {
    }

    public override string TypeOfVehicle { get; set; } = "Truck";
}