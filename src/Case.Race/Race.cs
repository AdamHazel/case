namespace Case.Race;

public class Race
{
    public Race(string raceTrack, Contestant[] contestants, int lengthOfTrackInKm)
    {
        RaceTrack = raceTrack;
        Contestants = contestants;
        LengthOfTrackInKm = lengthOfTrackInKm;
    }

    public Contestant[] Contestants { get; }

    public string RaceTrack { get; }
    
    public int LengthOfTrackInKm { get; }

    private TimeSpan _getContestantTotalHours(Contestant contestant)
    {
        decimal skillLevelDriver = contestant.Driver.SkillLevel;
        if (skillLevelDriver > contestant.Vehicle.HandelingLevel) skillLevelDriver = contestant.Vehicle.HandelingLevel;

        decimal averageSpeed = contestant.Vehicle.TopSpeed * (skillLevelDriver / contestant.Vehicle.HandelingLevel);
        decimal totalHours = LengthOfTrackInKm / averageSpeed;
        
        return TimeSpan.FromHours((double)totalHours);
    }

    private string _generateWinnerString((Contestant contestant, TimeSpan time) winner)
    {
        return
            $"{winner.contestant.Driver.Name} ({winner.contestant.Vehicle.Brand} - {winner.contestant.Vehicle.TypeOfVehicle}) with a time of " +
            $"{winner.time.Hours} hours, {winner.time.Minutes} min, {winner.time.Seconds} sec";
    }
    

    public void Start()
    {
        var winners = new List<(Contestant contestant, TimeSpan time)>();
        
        Console.WriteLine($"Starting race in {RaceTrack}");

        foreach (Contestant contestant in Contestants)
        {
            var totalTime = _getContestantTotalHours(contestant);

            if (winners.Count == 0)
            {
                winners.Add((contestant, totalTime));
            }
            else
            {
                if (totalTime == winners.Last().time)
                {
                    winners.Add((contestant, totalTime));
                }
                else if (totalTime < winners.Last().time)
                {
                    winners.Clear();
                    winners.Add((contestant, totalTime));
                }
            }
            
            Console.WriteLine($"Elapsed time for contestant, driving {contestant.Vehicle.Brand} ({contestant.Vehicle.TypeOfVehicle}), is {Math.Round(totalTime.TotalHours,1)} hours ({totalTime.Hours}:{totalTime.Minutes}:{totalTime.Seconds})");
        }
        
        switch (winners.Count)
        {
            case 0:
                Console.WriteLine("No contestants for today's race");
                break;
            case 1:
            {
                var winner = winners.Last();
                Console.WriteLine("\nWinner is " + _generateWinnerString(winner));
                Console.WriteLine("\n");
                break;
            }
            default:
            {
                Console.WriteLine("\nWe have a tie! Today's winners are: ");
                foreach (var winner in winners)
                    Console.WriteLine(_generateWinnerString(winner));
                Console.WriteLine("\n");
                break;
            }
        }
    }
}
