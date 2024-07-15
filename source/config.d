module config;

import std.algorithm;
import source;
import sdlang;

struct Config {
    public bool verbose;
    public string pacmanCommand;
    public string aurCommand;
    public string pacmanOutputFile;
    public string aurOutputFile;
    public Source[] sources;

    this(Tag tag) {
        verbose = tag.getTagValue!bool("verbose", false);
        pacmanCommand = tag.getTagValue!string("command_pacman", "pacman -Qqentt");
        aurCommand = tag.getTagValue!string("command_aur", "pacman -Qqemtt");
        pacmanOutputFile = tag.getTagValue("pacman_output_file", "user_pkgfile.txt");
        aurOutputFile = tag.getTagValue("aur_output_file", "user_pkgfile_aur.txt");
        tag.getTag("sources").all.tags.each! ((Tag T) =>
            sources ~= new Source(T)
        );
    }
}
