within BrineProp.Examples.Gas;
model Brine3Gas_Minimal
package Medium = BrineProp.BrineGas3Gas (ignoreNoCompositionInBrineGas=true);
  Medium.BaseProperties props;
equation
  props.p = 10*1e5;
  props.T = 293.15;
  props.Xi={0.1,0.1,0.1};
end Brine3Gas_Minimal;
