module source;

import sdlang;

class Source {
    public string source;
    public bool isUrl;

    this(Tag tag) {
        source = tag.getValue!string();
        isUrl = tag.getAttribute!bool("url", false);
    }

}
