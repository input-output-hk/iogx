{ l }:

let

  # If only nix had a type system...
  # 
  # type Field = String 
  #
  # type Value = any nix value 
  #
  # type ErrorTag 
  #   = "simple-type-mismatch"
  #   | "empty-string"
  #   | "unknown-enum"
  #   | "many-unknown-enums"
  #   | "empty-enum-list"
  #   | "path-does-not-exist"
  #   | "dir-does-not-have-file"
  #   | "missing-required-field"
  #   | "unknown-field"
  #
  # type FieldValidationResult 
  #   = { status = "success", field :: Field, value :: Value; }
  #   | { status = "failure", field :: Field, tag :: ErrorTag, [tag-specific-fields] }
  #
  # type FieldValidator 
  #   = Field -> Value -> FieldValidationResult
  # 
  # type Schema 
  #   = { [field-name] :: [FieldSchema] }
  #
  # type FieldSchema 
  #   = { validator :: FieldValidator
  #     , optional :: Bool
  #     , default :: Config -> Value }
  #
  # type SchemaValidationResult 
  #   = { status = "success", config :: Config }
  #   | { status = "failure", results :: [FieldValidationResult] }
  #
  # type Config 
  #   = { [field-name] :: Value }


  success = field: value: # Field -> Value -> FieldValidationResult
    {
      status = "success";
      inherit field value;
    };


  validators = # { [validator-name] -> FieldValidator }
    {
      path = field: value: # Field -> Value -> FieldValidationResult
        if l.typeOf value == "path" then
          success field value
        else {
          status = "failure";
          tag = "simple-type-mismatch";
          expected-type = "path";
          actual-type = l.typeOf value;
          inherit field value;
        };

      function = field: value: # Field -> Value -> FieldValidationResult
        if l.typeOf value == "function" then
          success field value
        else {
          status = "failure";
          tag = "simple-type-mismatch";
          expected-type = "function";
          actual-type = l.typeOf value;
          inherit field value;
        };

      attrset = field: value: # Field -> Value -> FieldValidationResult
        if l.typeOf value == "attrset" then
          success field value
        else {
          status = "failure";
          tag = "simple-type-mismatch";
          expected-type = "attrset";
          actual-type = l.typeOf value;
          inherit field value;
        };

      boolean = field: value: # Field -> Value -> FieldValidationResult
        if l.typeOf value == "bool" then
          success field value
        else {
          status = "failure";
          tag = "simple-type-mismatch";
          expected-type = "bool";
          actual-type = l.typeOf value;
          inherit field value;
        };

      string = field: value: # Field -> Value -> FieldValidationResult
        if l.typeOf value == "string" then
          success field value
        else {
          status = "failure";
          tag = "simple-type-mismatch";
          expected-type = "string";
          actual-type = l.typeOf value;
          inherit field value;
        };

      nonempty-string = field: value: # Field -> Value -> FieldValidationResult
        let
          result = V.string field value;
        in
        if result.status == "failure" then
          result
        else if value == "" then {
          status = "failure";
          tag = "empty-string";
          inherit field value;
        }
        else
          success field value;

      # FieldValidator -> Field -> Value -> FieldValidationResult
      null-or = validator: field: value:
        if value == null then
          success field value
        else
          validator field value;

      # FieldValidator -> [Value] -> Field -> Value -> FieldValidationResult
      enum = validator: gammut: field: value:
        let
          result = validator field value;
        in
        if result.status == "failure" then
          result
        else if !l.elem value gammut then {
          status = "failure";
          tag = "unknown-enum";
          inherit gammut field value;
        }
        else
          success field value;

      # FieldValidator -> [Value] -> Field -> [Value] -> FieldValidationResult
      enum-list = validator: gammut: field: list:
        let
          isFailure = value: (validator field value).status == "failure";
          result = l.findFirst isFailure (success field list) list;
        in
        if result.status == "failure" then
          result
        else
          let
            unknowns = l.subtractLists gammut list;
          in
          if l.length unknowns == 0 then
            success field list
          else {
            status = "failure";
            tag = "many-unknown-enums";
            value = list;
            unknown-values = unknowns;
            inherit gammut field;
          };

      # TODO Field -> [Value] -> FieldValidationResult === FieldValidator
      # FieldValidator -> [Value] -> Field -> [Value] -> FieldValidationResult
      nonempty-enum-list = validator: gammut: field: list:
        let
          result = V.enum-list validator gammut field list;
        in
        if result.status == "failure" then
          result
        else if l.length list == 0 then {
          status = "failure";
          tag = "empty-enum-list";
          value = list;
          inherit gammut field;
        }
        else
          success field list;

      # FieldValidator -> Field -> [Value] -> FieldValidationResult
      list = validator: field: list:
        let
          isFailure = value: (validator field value).status == "failure";
          result = l.findFirst isFailure (success field list) list;
        in
        if result.status == "failure" then
          result
        else
          success field list;

      path-exists = field: path: # Field -> Value -> FieldValidationResult
        let result = V.path field path; in
        if result.status == "failure" then
          result
        else if l.pathExists path then
          success field path
        else {
          status = "failure";
          tag = "path-does-not-exist";
          value = path;
          inherit field;
        };

      # Field -> Value -> Value -> FieldValidationResult
      dir-with-file = field: file: dir:
        let
          result = V.path-exists field dir;
        in
        if result.status == "failure" then
          result
        else
        # TODO why is readFileType missing?
          let
            contents = l.readDir dir;
            cabal-project = l.getAttrWithDefault file "" contents;
          in
          if cabal-project != "regular" then {
            status = "failure";
            tag = "dir-does-not-have-file";
            value = dir;
            inherit field file;
          }
          else
            success field dir;
    };


  V = validators;


  # Config -> Config -> Field -> FieldSchema -> FieldValidationResult
  validateField = final: config: field: schema:
    if l.hasAttr field config then
      schema.validator field config.${field}
    else
      if schema.optional then {
        status = "success";
        value = schema.default final;
      }
      else {
        status = "failure";
        tag = "missing-required-field";
        inherit field;
      };


  # Schema -> Config -> SchemaValidationResult
  matchConfigAgainstSchema = schema: config:
    let
      schema-fields = l.attrNames schema; # [String]

      config-fields = l.attrNames config; # [String]

      unknown-fields = l.subtractLists schema-fields config-fields; # [String]

      toUnknownFieldResult = field: {
        # Field -> FieldValidationResult
        status = "failure";
        tag = "unknown-field";
        inherit field;
      };

      unknown-fields-results = # [FieldValidationResult]
        map toUnknownFieldResult unknown-fields;

      known-fields-results = # [FieldValidationResult]
        l.mapAttrsToList (validateField __finalconfig__ config) schema;

      all-results = # [FieldValidationResult]
        unknown-fields-results ++ known-fields-results;

      failed-results = # [FieldValidationResult]
        l.filter (result: result.status == "failure") all-results;

      config-is-valid = # Bool
        l.all (result: result.status == "success") all-results;

      __finalconfig__ = # Config 
        let mkNameVal = result: { ${result.field} = result.value; };
        in l.recursiveUpdateMany (map mkNameVal all-results);

      schema-result = # SchemaValidationResult
        if config-is-valid then {
          status = "success";
          config = __finalconfig__;
        } else {
          status = "failure";
          results = failed-results;
        };
    in
    schema-result;


  resultToErrorString = result: # FieldValidationResult -> String 
    if result.tag == "simple-type-mismatch" then ''
      Type mismatch for field: `${result.field}`
      With value: `${toString result.value}`
      Expecting type: `${result.expected-type}`
      Actual type: `${result.actual-type}`
    ''
    else if result.tag == "empty-string" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      This field cannot be the empty string.
    ''
    else if result.tag == "unknown-enum" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      It must be one of: `${l.concatStringsSep "` - `" result.gammut}
    ''
    else if result.tag == "many-unknown-enums" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      Available values: `${l.concatStringsSep "` - `" result.gammut}
    ''
    else if result.tag == "empty-enum-list" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      This field cannot be the empty string.
    ''
    else if result.tag == "path-does-not-exist" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      This path does not exist.
    ''
    else if result.tag == "dir-does-not-have-file" then ''
      Invalid field: `${result.field}`
      With value: `${toString result.value}`
      The directory does not contain the expected file `${result.file}`
    ''
    else if result.tag == "missing-required-field" then ''
      Missing required field: `${result.field}`
    ''
    else if result.tag == "unknown-field" then ''
      Unknown field: `${result.field}`
    '' else '' 
      Internal error, please report this as a bug.
      ${toString result}
    '';

  # Schema -> Config -> Config | error 
  validateConfig = schema: config:
    let
      result = matchConfigAgainstSchema schema config; # SchemaValidationResult
    in
    if result.status == "success" then
      result.config
    else
      let
        errors = map resultToErrorString result.errors;
      in
      l.throw ''
        Your configuration has errors:
        ${l.concatStringsSep "\n\n" errors}
      '';
in
{
  inherit validators validateConfig matchConfigAgainstSchema;
}
