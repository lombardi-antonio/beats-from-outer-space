# Beats from Outer Space

![Beats from Outer Space](assets/PlaceholderBFOS.png)

Beats from Outer Space is a 2.5D, low poly, Top Down Space Shooter with a Mobile first approach in mind.

## Controls

Controls are intended to be "single finger" only utilizing gestures for the different movements and attacks.
Following Controls are already implemented:

- When touching the screen the game starts:
  - Time runs normally
  - Player shoots automatically
  - Music plays unaltered

![Touching the Screen](assets/controls/TouchingTheScreen.png)

- Lifting the finger from the screen causes:
  - Game time slows down drastically
  - Player stops shooting
  - music pitch lowers causing a slow down effect

![Touching the Screen](assets/controls/LiftTheFinger.png)

- Dragging the finger will:
  - let the player ship move towards a point slightly in front of the players finger
  - the ship movement does have a max velocity and will trail behind the finger if the player is too fast
  - max velocity is a prerequisite to perform a maneuver

## Music and Effects

Music shall be an integral part of the game.
Music pitch and also singe instruments shall be effected by the player and enemy movement and attacks.
