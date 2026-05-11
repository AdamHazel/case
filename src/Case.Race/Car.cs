namespace Case.Race;

public class Car : Vehicle
{
    public Car(string brand, int topSpeed, int handelingLevel) :
        base(brand, topSpeed, handelingLevel)
    {
    }

    public override string TypeOfVehicle { get; set; } = "Car";
}
