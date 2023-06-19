{ l }:

let

  # If only nix had a type system...
  # 
  # type Field = String 
  #
  # type Value = any nix value 
  #
  # type ErrorTag 
  #   = "type-mismatch"
  #   | "empty-string"
  #   | "unknown-enum"
  #   | "empty-list"
  #   | "path-does-not-exist"
  #   | "dir-does-not-have-file"
  #   | "missing-field"
  #   | "unknown-field"
  #   | "invalid-list-elem"
  # 
  # type FieldValidationResult 
  #   = { status = "success", field :: Field, value :: Value; }
  #   | { status = "failure", field :: Field, tag :: ErrorTag, [tag-specific-fields] }
  #
  # type FieldValidator 
  #   = Field -> Value -> FieldValidationResult
  # 
  # type Schema 
  #   = { [field-name] :: FieldValidator }
  #
  # type SchemaValidationResult 
  #   = { status = "success", config :: Config }
  #   | { status = "failure", errors :: [FieldValidationResult] }
  #
  # type Config 
  #   = { [field-name] :: Value }


  resultIsFailure = result: result.status == "failure";
  resultIsSuccess = result: result.status == "success";


  success = field: value: # Field -> Value -> FieldValidationResult
    {
      status = "success";
      inherit field value;
    };


  validators =
    {
      # String -> Field -> Value -> FieldValidationResult
      simple-type = type: field: value:
        if l.typeOf value == type then
          success field value
        else
          {
            status = "failure";
            tag = "type-mismatch";
            expected-type = type;
            actual-type = l.typeOf value;
            inherit field value;
          };

      path = V.simple-type "path"; # Field -> Value -> FieldValidationResult

      function = V.simple-type "lambda"; # Field -> Value -> FieldValidationResult

      attrset = V.simple-type "set"; # Field -> Value -> FieldValidationResult

      bool = V.simple-type "bool"; # Field -> Value -> FieldValidationResult

      string = V.simple-type "string"; # Field -> Value -> FieldValidationResult

      list = V.simple-type "list"; # Field -> [Value] -> FieldValidationResult

      nonempty-string = field: value: # Field -> Value -> FieldValidationResult
        if value == "" then
          {
            status = "failure";
            tag = "empty-string";
            inherit field value;
          }
        else
          V.string field value;

      # FieldValidator -> Field -> Value -> FieldValidationResult
      null-or = validator: field: value:
        if value == null then
          success field value
        else
          validator field value;

      # [Value] -> Field -> Value -> FieldValidationResult
      enum = gammut: field: value:
        if !l.elem value gammut then
          {
            status = "failure";
            tag = "unknown-enum";
            inherit gammut field value;
          }
        else
          success field value;

      # [Value] -> Field -> [Value] -> FieldValidationResult
      enum-list = gammut: field: list:
        V.list-of (V.enum gammut) field list;

      # [Value] -> Field -> [Value] -> FieldValidationResult
      nonempty-enum-list = gammut: field: list:
        let result = V.enum-list gammut field list; in
        if resultIsFailure result then
          result
        else if l.length list == 0 then
          {
            status = "failure";
            tag = "empty-list";
            value = list;
            inherit field;
          }
        else
          success field list;

      # FieldValidator -> Field -> [Value] -> FieldValidationResult
      list-of = validator: field: list:
        let result = V.list field list; in
        if resultIsFailure result then
          result
        else
          let
            results = map (validator field) list;
            first = l.findFirst resultIsFailure (success field list) results;
          in
          if resultIsSuccess first then
            success field list
          else
            {
              status = "failure";
              tag = "invalid-list-elem";
              inner = first;
              value = list;
              inherit field;
            };

      path-exists = field: path: # Field -> Value -> FieldValidationResult
        let result = V.path field path; in
        if result.status == "failure" then
          result
        else if l.pathExists path then
          success field path
        else
          {
            status = "failure";
            tag = "path-does-not-exist";
            value = path;
            inherit field;
          };

      # Value -> Field -> Value -> FieldValidationResult
      dir-with-file = file: field: dir:
        let result = V.path-exists field dir; in
        if result.status == "failure" then
          result
        else if !l.pathExists (dir + "/${file}") then
          {
            status = "failure";
            tag = "dir-does-not-have-file";
            value = dir;
            inherit field file;
          }
        else
          success field dir;
    };


  V = validators;


  # Config -> Field -> FieldValidator -> FieldValidationResult
  validateField = config: field: validator:
    if l.hasAttr field config then
      validator field config.${field}
    else
      {
        status = "failure";
        tag = "missing-field";
        inherit field;
      };


  # Schema -> Config -> SchemaValidationResult
  matchConfigAgainstSchema = schema: config:
    let
      schema-fields = l.attrNames schema; # [String]

      config-fields = l.attrNames config; # [String]

      unknown-fields = l.subtractLists schema-fields config-fields; # [String]

      toUnknownFieldResult = field: # Field -> FieldValidationResult
        {
          status = "failure";
          tag = "unknown-field";
          inherit field;
        };

      unknown-fields-results = # [FieldValidationResult]
        map toUnknownFieldResult unknown-fields;

      known-fields-results = # [FieldValidationResult]
        l.mapAttrsToList (validateField config) schema;

      all-results = # [FieldValidationResult]
        unknown-fields-results ++ known-fields-results;

      failed-results = # [FieldValidationResult]
        l.filter resultIsFailure all-results;

      config-is-valid = # Bool
        l.all resultIsSuccess all-results;

      final-config = # Config 
        let mkNameVal = result: { ${result.field} = result.value; };
        in l.recursiveUpdateMany (map mkNameVal all-results);

      schema-result = # SchemaValidationResult
        if config-is-valid then
          {
            status = "success";
            config = final-config;
          }
        else
          {
            status = "failure";
            errors = failed-results;
          };
    in
    schema-result;


  resultToErrorString = result: # FieldValidationResult -> String 
    if result.tag == "type-mismatch" then ''
      Invalid field: ${result.field}
      With value: ${toString result.value}
      Expecting type: ${result.expected-type}
      Actual type: ${result.actual-type}
    ''
    else if result.tag == "empty-string" then ''
      Invalid field: ${result.field}
      With value: ""
      This field cannot be the empty string
    ''
    else if result.tag == "unknown-enum" then ''
      Invalid field: ${result.field}
      With value: ${toString result.value}
      It must be one of: ${l.listToString result.gammut}
    ''
    else if result.tag == "empty-list" then ''
      Invalid field: ${result.field}
      With value: ${toString result.value}
      This field cannot be the empty string.
    ''
    else if result.tag == "path-does-not-exist" then ''
      Invalid field: ${result.field}
      With value: ${toString result.value}
      This path does not exist.
    ''
    else if result.tag == "invalid-list-elem" then
      let
        # A little hacky but gets the job done
        formatInner = l.composeManyLeft [
          resultToErrorString
          (l.splitString "\n")
          (l.drop 2) # Remove the first two lines of the inner error
          (l.concatStringsSep "\n")
        ];
      in
      '' 
        Invalid field: ${result.field}
        With value: ${l.listToString result.value}
        The list contains at least one invalid value: ${toString result.inner.value}
        ${formatInner result.inner}
      ''
    else if result.tag == "dir-does-not-have-file" then ''
      Invalid field: ${result.field}
      With value: ${toString result.value}
      The directory does not contain the expected file ${result.file}
    ''
    else if result.tag == "missing-field" then ''
      Missing field: ${result.field}
    ''
    else if result.tag == "unknown-field" then ''
      Unknown field: ${result.field}
    ''
    else '' 
      Internal error, please report this as a bug.
      ${toString result}
    '';

  # Schema -> Config -> Config | error 
  validateConfig = schema: config:
    let result = matchConfigAgainstSchema schema config; in # SchemaValidationResult
    if result.status == "success" then
      result.config
    else
      let errors = map resultToErrorString result.errors; in
      # TODO make this text red
      l.throw ''
      Your configuration has errors:

      ${l.concatStringsSep "\n" errors}
      '';
      
in

{
  inherit validators validateConfig matchConfigAgainstSchema;
}
