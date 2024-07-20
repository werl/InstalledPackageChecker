/**
Make my list_package shell script into a program that only writes the final output files
and takes in a config.sdl for a list of excluded packages.
*/

import std.stdio;
import std.file;
import sdlang;
import config;
import run;
import ws.globals;

void main()
{
	auto configFile = parseFile("config.sdl");
	verbose = configFile.getTagValue!bool("verbose", false);
	auto settings = Config(configFile);
	settings.execute();
}
