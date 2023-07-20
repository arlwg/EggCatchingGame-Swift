# EggCatchingGame-Swift

Ball Catcher is an engaging mobile game developed in Swift, utilizing SpriteKit for 2D game development. The game includes a variety of features such as physics-based object motion, a dynamic scoring system, level management, and touch controls, providing an immersive gaming experience.

Features

Object and Player Class Definition: The game implements basic classes for game objects and player, providing a solid foundation for game development.
Physics-Based Motion: The game uses CoreMotion to simulate gravity-affected motion for balls, creating an immersive and realistic gameplay experience.
Dynamic Scoring System: Scores are tracked and updated dynamically as the player catches balls, with lives decreasing if a ball touches the bottom of the screen.
Gameplay States: An enumeration is used to manage game states, handling transitions such as start, in-game, and game over states.
Collision Detection: The game handles collisions between the player and balls using the SKPhysicsContactDelegate protocol.
Object Spawning: The game features a system for spawning non-gravity and gravity-affected balls, with SKAction sequences controlling spawn rates and movement behavior.
Level Management: The game includes actions for starting new levels, running game over sequences, and transitioning to the end screen.
Touch Controls: The player's basket is moved along the x-axis according to the distance dragged on the screen, providing intuitive controls for the player.
