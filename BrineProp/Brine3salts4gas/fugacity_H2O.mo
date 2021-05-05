within BrineProp.Brine3salts4gas;
function fugacity_H2O
  "Calculation of fugacity coefficient according to (Duan 2003)"
  extends partial_fugacity_pTX;
algorithm
   phi:=GasData.fugacity_H2O_Duan2003(p, T);
end fugacity_H2O;
