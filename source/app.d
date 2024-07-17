/**
Make my list_package shell script into a program that only writes the final output files
and takes in a config.sdl for a list of excluded packages.
*/

import std.net.curl;
import std.stdio;
import std.file;
import std.string;
import std.process;
import std.algorithm;
import sdlang;
import ws.globals;

void main()
{
	auto configFile = parseFile("config.sdl");
	verbose = configFile.getTagValue!bool("verbose", false);
	auto settings = config.Config(configFile);
	settings.execute;

	auto testTag = configFile.getTag("test");
}
