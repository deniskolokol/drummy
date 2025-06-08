(
var win, panelTop, panelMain;
var tree, popup;

/*
`buffs` is a dictionary with the following structure:
{
    <RawPointer.asString> for "Claps": {
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": false,
        "buffer": nil,
        "children": [
            <RawPointer.asString> for "A_Clap_1.wav", // identify item as buffs.at(`this id`)
            <RawPointer.asString> for "B_Clap_1.wav"
        ]
    },
    <RawPointer.asString> for "A_Clap_1.wav": { // reference the item regardless of the depth
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": true,
        "buffer": nil, // not yet loaded
    },
    <RawPointer.asString> for "B_Clap_1.wav": {
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": true,
        "buffer": nil,
    },
    <RawPointer.asString> for "Kicks": {
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": false,
        "buffer": nil,
        "children": [
            <RawPointer.asString> for "A_Kick_1.wav",
            <RawPointer.asString> for "B_Kich_1.wav"
        ]
    },
    <RawPointer.asString> for "A_Kick_1.wav": {
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": true,
        Buffer(...) // already loaded
    },
    <RawPointer.asString> for "B_Kich_1.wav": {
        "obj": TreeViewItem,
        "path": dir.absolutePath,
        "isFile": true,
        Buffer(...),
    }
}
*/
var buffs = Dictionary.new;

// TODO: store in conf
var baseDir = "~/Music/material/Drum samples/513TubeDrumHits_Wav_SP/Samples";

var loadTree = { |dirName, tree|
	/*
	Walks the directory recursively and loads everything
	that can be loaded in a buffer.
	*/
	var loadTree_recursively = { |dirName_, tree, parent|
		var item, newParent;
		var addItem = { |name|
			/*
			Controls adding an ordinary item
			or a child of already existing item.
			*/
			var data = [name, nil, nil];
			if (parent.isNil.not) {
				parent.addChild(data);
			} {
				tree.addItem(data);
			};
		};

        PathName.new(dirName_).entries.do { |path|
			if (path.isFolder) {
				newParent = addItem.(path.folderName);

                // Register parent.
                buffs.put(newParent.id.asString, Dictionary.newFrom([
                    \obj, newParent,
                    \path, path.absolutePath,
                    \isFile, false,
                    \children, List.new
                ]));
                loadTree_recursively.(path.absolutePath, tree, newParent)
            } {
				if ("\.(wav|aif|aiff)$".matchRegexp(path.fileName)) {
					item = addItem.(path.fileName);
                    // Register soundfile.
                    buffs[item.id.asString] = Dictionary.newFrom([
                        \obj, item,
                        \path, path.absolutePath,
                        \isFile, true
                    ]);
                    buffs[parent.id.asString][\children].add(item.id.asString);
				};
			};
		};
	};
	loadTree_recursively.(dirName, tree);
	buffs;
};

var fillBranch = { |itemIds|
    itemIds.do { |id|
        var buf, loadBuf;
        if (buffs[id][\isFile] == true) {
            if (buffs[id][\buffer].isNil) {
                buf = Buffer.read(s, buffs[id][\path]);
                loadBuf = Task({
                    inf.do { |j|
                        if (buf.numFrames.isNil.not) {
                            buffs[id][\buffer] = buf;
                            buffs[id][\obj].setString(1, buf.numChannels.asString);
                            loadBuf.stop;
                        };
                        if (j > 500) {
                            postf("\n! Loading buffer % failed%!", buf.bufnum, buf.path ? "");
                            loadBuf.stop;
                        };
                        0.1.wait
                    };
                }).play(AppClock);
            };
        };
    }
};

// GUI: main window.
win = Window(
    "DM: samples",
    Rect(
        0,
        0,
        Window.screenBounds.width*0.35,
        Window.screenBounds.height
    )
);
win.view.decorator = FlowLayout(win.view.bounds);

panelTop = CompositeView(win, (win.view.bounds.width*0.98)@(win.view.bounds.height*0.05));
panelTop.decorator = FlowLayout(win.view.bounds);

Button(panelTop, 75@25).string_("Load");

panelMain = CompositeView(win, (win.view.bounds.width*0.96)@(win.view.bounds.height*0.85));
panelMain.decorator = FlowLayout(win.view.bounds);

tree = TreeView(panelMain, panelMain.bounds.width@panelMain.bounds.height);
tree.columns_(["name", "channels", "dur", "waveform"]);
tree.font = Font.defaultMonoFace;
tree.setColumnWidth(0, (tree.bounds.width * 0.33).asInteger);

// Call main function to load tree with the defaultd directory (baseDir)
loadTree.(baseDir, tree);
tree.onItemChanged_({ |view|
    // TODO: fill all children buffers upon element open
    fillBranch.value(
        buffs[view.currentItem.id.asString].atFail(\children, {List.new})
    )
});

win.front;

CmdPeriod.doOnce({
	buffs.values.do { |i| if (i[\isFile]) {i[\buffer].free}};
    win.close;
});

"running..."
)