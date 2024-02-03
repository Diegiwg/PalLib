# Palworld PalLib - Utility Library

![PalLib](logo-20x.jpg)

A utility library for developing mods for the game Palworld.

## Installation

1. To install, you first need UE4SS (<https://github.com/UE4SS-RE/RE-UE4SS/releases>).
2. Copy the **'PalLib'** folder into the *Mods/shared* folder of **UE4SS**.
3. Install other mods that use PalLib.

## Modules

### PalLib

Main module. Contains all modules of the library.

- PalLib:Version -> Property holding the current version of PalLib.
- PalLib:Dir -> Property holding the directory path of the game executable.
- PalLib.Log -> Function to log messages to the console.
- PalLib.Use -> Function to register in the console that Mod [X] is using PalLib.

### PalLib.Config

Module for manipulating configuration files. With this, you can provide your users with a simple configuration file that your mod can later utilize.

- PalLib.Config.Load -> Function to load and check the configuration file.

### PalLib.String

Module with utility functions for string manipulation.

- PalLib.String.Split -> Function to split a string into an PalLib.Array{object} of strings.
- PalLib.String.Trim -> Function to trim a string and return a new string.

### PalLib.Array

Module with utility functions for array manipulation.

- PalLib.Array{object} -> Object representing an array with the 'length' property.
- PalLib.Array.New -> Function to create a new PalLib.Array{object}.
- PalLib.Array.Length -> Function to get the length of an PalLib.Array{object}.
- PalLib.Array.Add -> Function to add an element to an PalLib.Array{object}.
- PalLib.Array.Remove -> Function to remove an element from an PalLib.Array{object}.
- PalLib.Array.ForEach -> Function to execute a function on each element of an array.

### PalLib.File

Module with utility functions for file manipulation.

- PalLib.File.Read -> Function to read a file and return its content as a string.

## Credits

PalLib is developed and maintained by Diegiwg.

## Contributing

Contributions are welcomed! Feel free to fork the repository and submit pull requests with your enhancements.
