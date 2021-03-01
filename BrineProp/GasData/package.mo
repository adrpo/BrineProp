within BrineProp;
package GasData "Molar masses and ion numbers of gases"
  //TODO: Limits mit in den Record


  extends PartialFlags;


  extends ComponentsOrder;

  constant SI.MolarMass M_CO2 = Modelica.Media.IdealGases.SingleGases.CO2.data.MM
  "0.0440095 [kg/mol]";
  constant Integer nM_CO2 = 1 "number of ions per molecule";
   constant SI.MolarMass M_N2 = Modelica.Media.IdealGases.SingleGases.N2.data.MM
  "0.0280134 [kg/mol]";
  constant Integer nM_N2 = 1 "number of ions per molecule";
   constant SI.MolarMass M_CH4 = Modelica.Media.IdealGases.SingleGases.CH4.data.MM
  "0.01604246 [kg/mol]";
  constant Integer nM_CH4 = 1 "number of ions per molecule";




























  annotation (Documentation(info=""));
end GasData;
