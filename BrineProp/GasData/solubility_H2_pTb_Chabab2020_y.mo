within BrineProp.GasData;
function solubility_H2_pTb_Chabab2020_y
                                          // mole fraction b_H2 / b/H2O
    // p is absolute pressure, here p_H2 + p_H2O
    // Debug.Print "p="; p / 100000#; "bar"
    input Real p;
    input Real T;
    input Types.Molality b_NaCl;
    output Real y_H2; //x_H2 in article
protected
    Real y_H2_0 = solubility_H2_pT_Chabab2020_y(p, T); //x_H2O_0 in article
    //print("x_H2_0: "+String(x_H2_0");
    Real[2] a = {0.018519,    -0.30185103};
algorithm
/*    if AssertLevel>0 then
       assert(ignoreTlimit or ignoreLimitH2_T or ((if molalities[iNaCl] > 0 then 273.15 else 323.15)<T and T<373.15), "Temperature out of validity range: T=" + String(T - 273.15) + ".\nTo ignore set ignoreLimitN2_T=true",aLevel);
       assert(ignoreLimitH2_p or ((if molalities[iNaCl] > 0 then 10e5 else 1e5)<p and p<203e5),"Pressure out of validity rangep=" + String(p/1e5) + " bar.\nTo ignore set ignoreLimitN2_p=true",aLevel);
       assert(ignoreLimitH2_b or molalities[iNaCl]<5,"Molality out of validity range: mola[NaCl]=" + String(molalities[iNaCl]) + " mol/kg.\nTo ignore set ignoreLimitH2_b=true",aLevel);
    end if;
*/
    //Debug.Print "ln(xH2/xH2°)"; a1 * b_NaCl ^ 2 + a2 * b_NaCl 'equ. 12
    y_H2 :=y_H2_0*exp(a[1]*b_NaCl^2 + a[2]*b_NaCl);         //x_H2 (equ. 12)
//    print("y_H2: " + String( y_H2)); //equ. 13

end solubility_H2_pTb_Chabab2020_y;
