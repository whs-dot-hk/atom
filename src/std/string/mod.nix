{
  upperChars = mod.stringToChars "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
  lowerChars = mod.stringToChars "abcdefghijklmnopqrstuvwxyz";

  stringToChars = s: builtins.genList (p: builtins.substring p 1 s) (builtins.stringLength s);

  /**
    Convert a string to lowercase by replacing all uppercase characters with their lowercase equivalents.

    # Examples

    ```nix
    ToLower "FOO" => "foo"
    ToLower "Hello World" => "hello world"
    ```

    # Type

    ```
    toLowerCase :: String -> String
    ```

    # Parameters

    - `str`: The string to convert.

    # Return Value

    The input string with all uppercase characters converted to lowercase.
  */
  ToLower = builtins.replaceStrings mod.upperChars mod.lowerChars;

  ToLowerCase = mod.toLowerCase;
}
