within BrineProp.Examples.UnitTests;
model UnitTestsLiquid "To be filled..."

  package Medium_3s = BrineProp.Brine3salts (ignoreLimitSalt_p={false,true,true});
  Medium_3s.BaseProperties props_3s;

  package Medium = Brine3salts3gas (ignoreLimitN2_T=true);
  Medium.BaseProperties props_3s3g;
equation
  props_3s.p = 455e5;
  props_3s.T = 145+273.15;
  props_3s.Xi = {0.082870031,0.00486001,0.125914128};
  assert(abs(props_3s.d-1127.8458262083673)<1e9, "Not the expecteded density!");

  props_3s3g.p = 455e5;
  props_3s3g.T = 145+273.15;
  props_3s3g.Xi = {0.082870031,0.00486001,0.125914128,1.6E-6, 465.6E-6, 49.9E-6};//-2313 m
  assert(abs(props_3s3g.d-1127.8458262083673)<1e9, "Not the expecteded density!");

//   print(String(props_3s.d-1127.85417379));

  annotation ();
end UnitTestsLiquid;
