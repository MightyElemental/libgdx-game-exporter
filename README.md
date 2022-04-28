# libGDX Game Exporter
A simple script to generate bundled versions of libgdx games.

## What does it do?
- This script starts by verifying the game jar file has been built
  - The script will build it if not
- It will then rename the game jar file to whatever is set in the script's ``gamename`` tag
- Windows and Linux versions of the Adoptium JRE will be downloaded from their git respository and hash checked
- [Packr](https://github.com/libgdx/packr/) will be downloaded from its git repository
- The script will then use Packr to bundle the game with the different JREs
- Finally, the script archives the game bundles so they can be distributed easily

## How to use
- This is designed to work with git projects with tagged commits
  - Ensure the project uses git and the currently checked out commit is tagged with a version
- Ensure the correct JRE is in use for both your gdx game and the script
  - The script uses java 11 by default but libGDX may be different by default
- Change the ``mainclass`` tag in the script to point to your game's main class
- Change the ``gamename`` tag in the script to what you want the exported file to be called
  - Exclude the version as this will be added automatically
- Run the script by running ``./build-exec.sh`` in the terminal