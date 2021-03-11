within BrineProp.Examples.Liquid;
model UnitTestsLiquid "To be filled..."

  package Medium = BrineProp.Brine3salts (ignoreLimitSalt_p={false,true,true});
  Medium.BaseProperties props;

  Medium.ThermodynamicState state = Medium.setState_pTX(10e5, 300, props.X);
  Medium.ThermodynamicState state2 = Medium.setState_phX(10e5, 1e6, props.X);

equation
  props.p = 455e5;
  props.T = 145+273.15;
  props.Xi = {0.082870031,0.00486001,0.125914128};
  assert(abs(props.d-1127.8458262083673)<1e9, "Not the expecteded density!");


//   print(String(props_3s.d-1127.85417379));

  annotation ();
end UnitTestsLiquid;
