{
  upperChars = mod.stringToChars "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  lowerChars = mod.stringToChars "abcdefghijklmnopqrstuvwxyz";

  stringToChars = s: std.genList (p: std.substring p 1 s) (std.stringLength s);

  ToLower = std.replaceStrings mod.upperChars mod.lowerChars;

  ToLowerCase = mod.toLowerCase;
}
