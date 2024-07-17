module run;

import std.algorithm;
import std.file;
import std.net.curl;
import std.parallelism;
import std.process;
import std.stdio;
import sdlang;
import ws.globals;

class Run {
    public string runName;
    public string command;
    public string outputFile;
    public Source[] sources;

    this(Tag tag) {
        runName = tag.getValue!string();
        command = tag.getTagValue!string("command");
        outputFile = tag.getTagValue!string("outputFile");
        if (tag.getTag("sources") is null)
            return;
        tag.getTag("sources").all.tags.each! ((Tag T) =>
            sources ~= new Source(T)
        );
    }

    this(string name, string comm, string file, Source[] s) {
        runName = name;
        command = comm;
        outputFile = file;
        sources = s;
    }

    public void execute() {
        writefln("Running %s...", runName);
        // determine which installed packages are not on the excluded list
        string[] addedPacks = getNewPackages();

        // Tell the user how many packagers were found
        writefln("Found %s new packages!", addedPacks.length);

        auto output = File(outputFile, "w");

        foreach (pkg; addedPacks) {
            output.writeln(pkg);
        }
    }

    private string[] getExclusions() {
        if (sources.length is 0)
            return null;

        string[] exclusions;
        foreach (source; sources) {
            exclusions ~= source.getExclusions();
        }
        return exclusions;
    }

    string[] getNewPackages() {
        string[] newPacks;


        // find packages to exclude from the list and put them in an array
        string[] exclusions = getExclusions();
        string[] installed = getInstalled();

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

    private string[] getInstalled() {
        // run pacman and get a list of all installed packages that are not dependencies
        auto pipe = pipeShell(command);
        // wait for previous command to run
        wait(pipe.pid());

        string[] installed;
        // put the list of packages into an array
        foreach (line; pipe.stdout.byLine()) {
            installed ~= line.dup;
        }
        return installed;
    }
}

class Source {
    public string source;
    public bool isUrl;

    this(Tag tag) {
        source = tag.getValue!string();
        isUrl = tag.getAttribute!bool("url", false);
    }

    this(string s, bool isUrl) {
        source = s;
        this.isUrl = isUrl;
    }

    public string[] getExclusions() {
        string[] exclusions;

        if(isUrl) {
            foreach (line; byLine(source)) {
                exclusions ~= line.dup;
            }
        } else {
            auto file = File(source);
            foreach (line; file.byLine()) {
                exclusions ~= line.dup;
            }
        }
        return exclusions;
    }

}
