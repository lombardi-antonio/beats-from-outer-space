using Godot;
using System;

public class Space : Area
{
    [Export]
    public float Something = 0.0;

    [Signal]
    delegate void LevelCleaed();
    delegate void SpawnerDefeated();

    public float TimeScale = 1.0f;
    public int Points;
    public int Wave = 0;
    public bool mMovementDisabled;
    public bool ReadyForNextSpawn = false;



    public override void _Ready()
    {
        GD.Print("Hello there...");
    }
}