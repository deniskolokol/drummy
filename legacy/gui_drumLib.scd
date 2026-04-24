(
var win, panelTop, panelMain;
var tree, popup;

var names = ["black", "white", "red", "green", "blue", "cyan", "magenta", "yellow"];
var buffs = ();
var colors = names.collect{|str| Color.perform(str.asSymbol)};

// TODO: store in conf
// var baseDir = "/Users/deko/Music/material/Drum\ samples/513TubeDrumHits_Wav_SP/Samples/";

// XXX test
var baseDir = "/Users/deko/Documents/dev_music/viDrum/samples/";

var loadTree = { |dirName, tree|
	/*
	Walks the directory recursively and loads everything
	that can be loaded in a buffer.
	*/

	var scroot;
	var buf;
	var loadBuf;

	// TODO:
	// - load buffers
	// - connect buffers to the elements of the tree

	var loadTree_recursively = { |dirName_, tree, parent|
		var item, newParent;
		var addItem = { |item|
			/*
			Controls adding an ordinary item
			or a child of already existing item.
			*/
			var data = [item[\name], item[\channels], item[\dur]];
			if (parent.isNil.not) {
				parent.addChild(data);
			} {
				tree.addItem(data);
			};
		};

		PathName.new(dirName_).entries.do { |path|
			if (path.isFolder) {
				item = (
					name: path.folderName,
					path: path,
					channels: \,
					dur: \
				);
				newParent = addItem.(item);
				buffs = loadTree_recursively.(path.absolutePath, tree, newParent)
			} {
				if ("\.(wav|aif|aiff)$".matchRegexp(path.fileName)) {
					item = addItem.((
						name: path.fileName,
						path: path,
						channels: \,
						dur: \
						// channels: buf.numChannels,
						// dur: buf.duration
					));
					buf = Buffer.read(s, path.absolutePath);
					loadBuf = Task({
						inf.do { |j|
							if (buf.numFrames.isNil.not) {
								postf("\nloaded %\n", buf);
								buffs[item] = buf;
								loadBuf.stop;
							};
							if (j > 500) {
								postf("\n! Loading buffer % failed%!",
									buf.bufnum, buf.path ? ""
								);
								loadBuf.stop;
							};
							post(".");
							0.1.wait
						};
					}).play;
				};
			};
		};
		buffs
	};

	// save scroot
	scroot = PathName.scroot;

	// all paths will be relative to this
	PathName.scroot = PathName.new(dirName);

	loadTree_recursively.(dirName, tree);

	// return to original scroot
	PathName.scroot = scroot;

	buffs;
};

win = Window("DM: samples", Rect(Window.screenBounds.width*0.65, 0, Window.screenBounds.width*0.35, Window.screenBounds.height));
win.view.decorator = FlowLayout(win.view.bounds);


panelTop = CompositeView(win, (win.view.bounds.width*0.98)@(win.view.bounds.height*0.05));
panelTop.decorator = FlowLayout(win.view.bounds);

Button(panelTop, 75@25).string_("Load");

panelMain = CompositeView(win, (win.view.bounds.width*0.96)@(win.view.bounds.height*0.85));
panelMain.decorator = FlowLayout(win.view.bounds);

tree = TreeView(panelMain, panelMain.bounds.width@panelMain.bounds.height);
tree.columns_(["name", "channels", "dur"]);
tree.font = Font.defaultMonoFace;
tree.setColumnWidth(0, 230);
tree.setColumnWidth(1, 50);
tree.setColumnWidth(2, 50);

loadTree.(baseDir, tree);
tree.onItemChanged_({ |view|
	[view.currentItem.strings, buffs[view.currentItem]].postln;
});

win.front;

CmdPeriod.doOnce({
	buffs.values.do { |buff| buff.free };
    win.close;
});
)