module config;

import std.algorithm;
import run;
import sdlang;

struct Config {
    
    public Run[] runs;

    this(Tag tag) {
        tag.getTag("runs").all.tags.each! ((Tag T) =>
            runs ~= new Run(T)
        );
    }

    public void execute() {
        runs.each! ((Run r) =>
            r.execute()
        );
    }
}