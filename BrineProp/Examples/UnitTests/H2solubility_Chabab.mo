within BrineProp.Examples.UnitTests;
model H2solubility_Chabab
  package Medium = BrineProp.Brine3salts4gas (ignoreNoCompositionInBrineGas=true);
//package Medium = Modelica.Media.Air.SimpleAir;
//package Medium = PartialBrineGas;
//  Medium.BaseProperties props;

equation
  assert(abs(GasData.solubility_H2_pT_Chabab2020_y(1e7, 323.15) - 0.001272328226268451)< 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_y(1e7,323.15,1) - 0.000958406222692535) < 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_molality(1e7,323.15,1) - 0.0532507008145311) < 1e-8, "Nope");
  assert(abs(0.00396636796628623-Medium.solubility_H2_pTX_Chabab2020_molality(50e5, 323.15,{0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652,0.00001,0.789792838},Medium.MM_vec,15e5))<1e-8, "Nope");
  assert(abs(6.31433733266665E-06-Medium.solubility_H2_pTX_Chabab2020(50e5, 323.15,{0.0839077010751,0.00253365118988,0.122786737978,0.00016883,0.00073459,0.000065652,0.00001,0.789792838},Medium.MM_vec, 15e5,false))<1e-8, "Nope");
   annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end H2solubility_Chabab;
