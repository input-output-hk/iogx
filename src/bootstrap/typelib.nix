{ l }:

let
  success = {
    status = "ok";
  };

  typeValidators = {

    boolean = x:
      if l.typeOf x == "boolean" then
        success
      else {
        status = "failure";
        what = "simple-type-mismatch";
        expected-type = "boolean";
        actual-type = l.typeOf x;
        value = x;
      };

    string = x:
      if l.typeOf x == "string" then
        success
      else {
        status = "failure";
        what = "simple-type-mismatch";
        expected-type = "string";
        actual-type = l.typeOf x;
        value = x;
      };

    enum = t: xs: x:
      let
        result = typeValidators.${t} x;
      in
      if result.status == "failure" then
        result
      # {
      #   status = "failure";
      #   what = "enum-type-mismatch";
      #   gammut = xs;
      #   expected-type = t;
      #   actual-type = l.typeOf x;
      #   value = x;
      # }
      else if !l.elem x xs then {
        status = "failure";
        what = "enum-unknown-element";
        gammut = xs;
        value = x;
      }
      else
        success;

    enum-list = t: gammut: xs:
      let
        result = l.findFirst (x: (typeValidators.${t} x).status == "failure") success xs;
      in
      if result.status == "failure" then
        result
      # {
      #   status = "failure";
      #   what = "enum-list-type-mismatch";
      #   gammut = xs;
      #   values = ys;
      #   inner-failure = result;
      # }
      else
        let
          unknowns = l.subtractLists xs gammut;
        in
        if l.lengthList unknowns == 0 then
          success
        else {
          status = "failure";
          what = "enum-list-unknown-values";
          gammut = gammut;
          values = xs;
          unknwon-values = unknowns;
        };

    nonempty-enum-list = t: gammut: xs:
      let
        result = typeValidators.enum-list t gammut xs;
      in
      if result.status == "failure" then
        result
      else if l.lengthList xs == 0 then {
        status = "failure";
        what = "enum-list-empty";
        gammut = gammut;
        values = xs;
      }
      else
        success;

    list = t: xs:
      let
        result = l.findFirst (x: (typeValidators.${t} x).status == "failure") success xs;
      in
      if result.status == "failure" then
        result
      else
        success;
  };

  validateField = f: x:
    let
      result = f.type-validator x;
    in
    if result.status == "failure" then
      result

        flakeopts-spec = {
    inputs = {
    type = "attrset";
    optional = false;
    typeMisMatchWarning = ''
        [iogx] The `inputs` field has the wrong type.
        Just do this:
        outputs = inputs: inputs.iogx.mkFlake {
          inherit inputs;
          ...
        }
      '';
    };

    debug = {
    type = "boolean";
    optional = true;
    default = true;
    defaultingWarning = ''
        [iogx] The `debug` configuration field was not set: defaulting to `true`
      '';
    typeMismatchWarning = ''
        [iogx] The `debug` field is supposed to be a boolean.
      '';
    };

    flakeOutputsPrefix = {
    type = "string";
    optional = true;
    default = "";
    defaultingWarning = ''
        [iogx] The `flakeOutputsPrefix` configuration field was not set: defaulting to `""`.
      '';
    };

    systems = {
    type = liftOfEnums ["x86_64-linux" "x86_64-darwin"];
    optional = true;
    default = ["x86_64-linux" "x86_64-darwin"];
    }
    };

    validateType = t: x:

    optionalFile = path:
    if l.pathExists path then import path else _: { };
