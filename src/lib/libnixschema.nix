{ l }:

let

  # If only nix had a type system...
  # 
  # type Field = String 
  #
  # type Value = Any Nix Value 
  #
  # type ErrorTag 
  #   = "type-mismatch"
  #   | "empty-string"
  #   | "unknown-enum"
  #   | "empty-list"
  #   | "path-does-not-exist"
  #   | "dir-does-not-have-file"
  #   | "missing-requred-field"
  #   | "unknown-field"
  #   | "invalid-list-elem"
  #   | "invalid-attr-elem"
  #   | "inner-schema-failure";
  # 
  # type FieldValidationResult 
  #   = { status = "success", field :: Field, value :: Value; }
  #   | { status = "failure", field :: Field, tag :: ErrorTag, [tag-specific-fields] }
  #
  # type TypecheckFunc = Field -> Value -> FieldValidationResult
  # 
  # type FieldValidator 
  #   = { type :: TypecheckFunc }
  #   | { type :: TypecheckFunc, default :: Config -> Value }
  #   | { type :: TypecheckFunc, default :: Value }
  # 
  # type Schema 
  #   = { [field-name] :: FieldValidator }
  #
  # type SchemaValidationResult 
  #   = { status = "success", config :: Config }
  #   | { status = "failure", errors :: [FieldValidationResult], errmsg :: String }
  #
  # type Config 
  #   = { [field-name] :: Value }
  # 
  # type FinalConfig = Config 


  # SchemaValidationResult -> Bool
  resultIsFailure = result: result.status == "failure";


  # SchemaValidationResult -> Bool
  resultIsSuccess = result: result.status == "success";


  # Field -> Value -> FieldValidationResult === TypecheckFunc
  success = field: value: 
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

      any = success;

      path = V.simple-type "path"; # Field -> Value -> FieldValidationResult

      function = V.simple-type "lambda"; # Field -> Value -> FieldValidationResult

      attrset = V.simple-type "set"; # Field -> Value -> FieldValidationResult

      bool = V.simple-type "bool"; # Field -> Value -> FieldValidationResult

      string = V.simple-type "string"; # Field -> Value -> FieldValidationResult

      list = V.simple-type "list"; # Field -> [Value] -> FieldValidationResult

      drv = V.simple-type "derivation"; # Field -> Value -> FieldValidationResult

      # Field -> Value -> FieldValidationResult
      nonempty-string = field: value: 
        if value == "" then
          {
            status = "failure";
            tag = "empty-string";
            inherit field value;
          }
        else
          V.string field value;

      # TypecheckFunc -> Field -> Value -> FieldValidationResult
      null-or = check: field: value:
        if value == null then
          success field value
        else
          check field value;

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

      # TypecheckFunc -> Field -> [Value] -> FieldValidationResult
      list-of = check: field: list:
        let result = V.list field list; in
        if resultIsFailure result then
          result
        else
          let
            results = map (check field) list;
            firstFailure = l.findFirst resultIsFailure (success field list) results;
          in
          if resultIsSuccess firstFailure then
            success field list
          else
            {
              status = "failure";
              tag = "invalid-list-elem";
              inner = firstFailure;
              value = list;
              inherit field;
            };

      # TypecheckFunc -> Field -> AttrSet -> FieldValidationResult
      attrset-of = check: field: set:
        let result = V.attrset field set; in
        if resultIsFailure result then
          result
        else
          let
            results = l.mapAttrsToList check set;
            firstFailure = l.findFirst resultIsFailure (success field set) results;
          in
          if resultIsSuccess firstFailure then
            success field set
          else
            {
              status = "failure";
              tag = "invalid-attr-elem";
              inner = firstFailure;
              value = set;
              inherit field;
            };

      # Field -> Value -> FieldValidationResult
      path-exists = field: path: 
        let result = V.path field path; in
        if resultIsFailure result then
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
        if resultIsFailure result then
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

      # Schema -> Field -> Value -> FieldValidationResult
      schema = schema': field: config: 
        let result = matchConfigAgainstSchema schema' config; in 
        if resultIsFailure result then
          {
            status = "failure";
            tag = "inner-schema-failure"; 
            value = config;
            inner = l.head result.errors;
            inherit field;
          }
        else 
          success field config;
    };


  V = validators;


  # FinalConfig -> Config -> Field -> FieldValidator -> FieldValidationResult
  validateField = __config__: config: field: validator: 
    if l.hasAttr field config then
      validator.type field config.${field}
    else if validator ? default then 
      # FIXME it's ambiguous whether it's a function value or a (Config -> Value)
      if l.typeOf validator.default == "lambda" then 
        success field (validator.default __config__)
      else
        success field validator.default
    else 
      {
        status = "failure";
        tag = "missing-requred-field"; 
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
        l.mapAttrsToList (validateField __config__ config) schema;
        #                               ^^^^^^^^^^ 
        # Threading the FinalConfig "before" it's defined: Laziness + Recursion == Magic

      all-results = # [FieldValidationResult]
        unknown-fields-results ++ known-fields-results;

      failed-results = # [FieldValidationResult]
        l.filter resultIsFailure all-results;

      config-is-valid = # Bool
        l.all resultIsSuccess all-results;

      __config__ = # Config 
        let mkNameVal = result: { ${result.field} = result.value; };
        in l.recursiveUpdateMany (map mkNameVal all-results);

      schema-result = # SchemaValidationResult
        if schema ? __passthrough then # TODO revisit this __passthrough business
          {
            status = "success";
            config = config;
          }
        else if config-is-valid then
          {
            status = "success";
            config = __config__;
          }
        else
          {
            status = "failure";
            errors = failed-results;
            errmsg = l.concatStringsSep "\n" (map resultToErrorString failed-results);
          };
    in
    schema-result;


  # Int -> FieldValidationResult -> String 
  truncateInnerResult = drop: # A little hacky but gets the job done
    l.composeManyLeft [
      resultToErrorString
      (l.splitString "\n")
      (l.drop drop) # Remove the first n lines of the inner error
      (l.concatStringsSep "\n")
    ];


  # FieldValidationResult -> String 
  resultToErrorString = result: 
    if result.tag == "type-mismatch" then ''
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      Expecting type: ${result.expected-type}
      Actual type: ${result.actual-type}''

    else if result.tag == "empty-string" then ''
      Invalid field: ${result.field}
      With value: ""
      This field cannot be the empty string''

    else if result.tag == "unknown-enum" then ''
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      It must be one of: ${l.valueToString result.gammut}''

    else if result.tag == "empty-list" then ''
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      This field cannot be the empty string.''

    else if result.tag == "path-does-not-exist" then ''
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      This path does not exist.''

    else if result.tag == "inner-schema-failure" then '' 
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      Inner schema error:
      ${truncateInnerResult 0 result.inner}''

    else if result.tag == "invalid-list-elem" then '' 
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      The list contains an invalid value: ${l.valueToString result.inner.value}
      ${truncateInnerResult 2 result.inner}''

    else if result.tag == "invalid-attr-elem" then '' 
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      The attrset contains the invalid key: ${result.inner.field}
      With value: ${l.valueToString result.inner.value}
      ${truncateInnerResult 2 result.inner}''

    else if result.tag == "dir-does-not-have-file" then ''
      Invalid field: ${result.field}
      With value: ${l.valueToString result.value}
      The directory does not contain the expected file ${result.file}''

    else if result.tag == "missing-requred-field" then ''
      Missing required field: ${result.field}''

    else if result.tag == "unknown-field" then ''
      Unknown field: ${result.field}''

    else '' 
      Internal error, please report this as a bug.
      ${l.valueToString result}'';


  # Schema -> Config -> Config | error 
  validateConfigOrThrow = schema: config: mkErrmsg:
    let result = matchConfigAgainstSchema schema config; in # SchemaValidationResult
    if resultIsSuccess result then
      result.config
    else
      l.pthrow (mkErrmsg { inherit result; });
      
in

{
  inherit 
    validators 
    validateConfigOrThrow 
    resultToErrorString
    matchConfigAgainstSchema;
}
