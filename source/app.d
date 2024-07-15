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
import source;
import config;

void main()
{
	auto configFile = parseFile("config.sdl");
	auto settings = config.Config(configFile);

	writeln("Running primary package list");
	checkPackages(settings.pacmanCommand, settings.sources, settings.pacmanOutputFile, settings.verbose);

	writeln("Rinning AUR package list");
	checkPackages(settings.aurCommand, settings.sources, settings.aurOutputFile, settings.verbose);
}

void checkPackages(string command, Source[] sources, string outputFile, bool verbose = false) {
	// run pacman and get a list of all installed packages that are not dependencies
	auto pipe = pipeShell(command);
	// wait for previous command to run
	wait(pipe.pid());

	string[] installed;
	// put the list of packages into an array
	foreach (line; pipe.stdout.byLine()) {
		installed ~= line.dup;
	}

	// find packages to exclude from the list and put them in an array
	string[] excludedPackages = getExclusions(sources);

	// determine which installed packages are not on the excluded list
	string[] addedPacks = getNewPackages(installed, excludedPackages, verbose);

	// Tell the user how many packagers were found
	writefln("Out of %s installed packages, found %s new packages!", installed.length, addedPacks.length);

	auto output = File(outputFile, "w");

	foreach (pkg; addedPacks) {
		output.writeln(pkg);
	}
}

string[] getExclusions(Source[] sources) {
	string[] exclusions;

	foreach (source; sources) {
		if(source.isUrl) {
			foreach (line; byLine(source.source)) {
				exclusions ~= line.dup;
			}
		} else {
			auto file = File(source.source);
			foreach (line; file.byLine()) {
				exclusions ~= line.dup;
			}
		}
	}
	return exclusions;
}

string[] getNewPackages(string[] installed, string[] exclusions, bool verbose) {
	string[] newPacks;

	foreach(pack; installed) {
		if (verbose) {
			writef("Searching for: %s...", pack);
		}
		bool found = false;
		foreach(exclude; exclusions)
		{
			if (pack == exclude) {
				found = true;
				break;
			}
		}

		if (found) {
			if (verbose) {
				writeln(" Package found! Skipping");
			}
			continue;
		}
		if (verbose) {
			writeln(" Package not found. Added to list");
		}
		newPacks ~= pack;
	}
	return newPacks;
}
