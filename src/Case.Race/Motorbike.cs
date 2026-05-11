namespace Case.Race;

public class Motorbike: Vehicle
{
    public Motorbike(string brand, int topSpeed, int handelingLevel) :
        base(brand, topSpeed, handelingLevel)
    {
    }

    public override string TypeOfVehicle { get; set; } = "Motorbike";
}