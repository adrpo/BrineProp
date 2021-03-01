within BrineProp.Examples.UnitTests;
model H2solubility_Chabab
  package Medium = BrineProp.Brine3salts3gas (ignoreNoCompositionInBrineGas=true);
//package Medium = Modelica.Media.Air.SimpleAir;
//package Medium = PartialBrineGas;
//  Medium.BaseProperties props;

equation
  assert(abs(GasData.solubility_H2_pT_Chabab2020_y(1e7, 323.15) -
    0.001272328226268451) < 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_y(
    1e7,
    323.15,
    1) - 0.0009584062226925354) < 1e-8, "Nope");
  assert(abs(GasData.solubility_H2_pTb_Chabab2020_molality(
    1e7,
    323.15,
    1) - 0.05325070081453114) < 1e-8, "Nope");
  assert(abs(Medium.solubility_H2_pTX_Chabab2020_molality(102e5, 323.15,{0.0552160106873965,0,0,0,0,0,0}, 100e5, Modelica.Media.Water.WaterIF97_pT.saturationPressure(323.15))-0.05325070081453114)<1e-8, "Nope");
  print("Hallo");
   annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)));
end H2solubility_Chabab;
