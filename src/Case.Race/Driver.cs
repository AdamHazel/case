namespace Case.Race;

public class Driver
{
    public Driver(string name, int skillLevel)
    {
        Name = name;
        SkillLevel = skillLevel;
    }

    public string Name { get; }

    public decimal SkillLevel { get; }
}
