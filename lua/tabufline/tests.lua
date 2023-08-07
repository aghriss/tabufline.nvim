local paths = {
	["0"] = "/home/f4",
	["1"] = "/home/f1/f2",
	["2"] = "/b2/home/f1/f2",
	["3"] = "/b3/home/f1/f2",
	["4"] = "/b1/b2/home/f1/f2",
	["5"] = "/home/b2/f3",
	["6"] = "/f3",
	["7"] = "/home/b3/f3",
	["8"] = "/b4/lome/f1/f2",
	["9"] = "/b4/gome/f1/f2",
}
Pr(paths)
Pr(require("tabufline.path").reduce_paths(paths))
