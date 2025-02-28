# love2d_dogethesharks

My first game using Lua and LÖVE2D. This game challenges you to dodge falling obstacles and collect power-ups to boost your score and increase the difficulty. It's a fun, fast-paced game that helped me learn the basics of game development with Lua and LÖVE2D.

## Overview

In **love2d_dogethesharks**, you control a player sprite that must avoid falling blocks while collecting power-ups. The game features:
- **Dynamic Gameplay:** The player's speed increases as your score grows.
- **Stacking Multipliers:** Collect power-ups to double your score multiplier. Each power-up stacks, making the game progressively more challenging.
- **Retry Mechanism:** When you crash into a block, the game shows a "Game Over" screen with a retry button.

## Features

- **Player Movement:** Use the left and right arrow keys to navigate.
- **Falling Blocks:** Blocks fall from the top at varying speeds and sizes. Their speed increases as your multiplier increases.
- **Power-Ups:** Collect power-up sprites to stack score multipliers and boost your scoring potential.
- **Dynamic Difficulty:** The game adapts by reducing spawn intervals as your multiplier increases.
- **Modular Code:** The project is broken into separate Lua modules (player, block, power-up, game) for clarity and maintainability.

## Installation

1. **Download LÖVE2D:**  
   Visit [https://love2d.org/](https://love2d.org/) and download the latest version of LÖVE2D for your operating system.

2. **Clone or Download the Repository:**  
   Clone the repository or download the ZIP file of this project.

3. **Assets:**  
   Ensure that the `assets` folder is in the project directory with the following files:
   - `assets/player2.png`
   - `assets/block1.png`
   - `assets/block2.png`
   - `assets/block3.png`
   - `assets/block4.png`

## Running the Game

- **Via Command Line:**  
  Open your terminal/command prompt, navigate to the project folder, and run:
  ```bash
  run.bat


  love2d_dogethesharks/
├── main.lua
├── game.lua
├── player.lua
├── block.lua
├── powerup.lua
└── assets/
    ├── player2.png
    ├── block1.png
    ├── block2.png
    ├── block3.png
    └── block4.png

For any questions or feedback, please contact me.
