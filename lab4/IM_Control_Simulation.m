mdl = "IM_Control_Sim";
simIn = Simulink.SimulationInput(mdl);

simIn = simIn.setVariable("par", par);
simIn = simIn.setVariable("im", im);
simIn = simIn.setVariable("incenc", incenc);
simIn = simIn.setVariable("Fw", Fw);

t = (0:par.Ts:0.01)';

omega_ref  = 0  * ones(size(t));
lambda_ref = 0.08 * ones(size(t));

u1 = timeseries(omega_ref,  t);  u1.Name = "omega_ref";
u2 = timeseries(lambda_ref, t);  u2.Name = "lambda_ref";

% Dataset in Root-Inport-Reihenfolge: Inport1, Inport2
ds = Simulink.SimulationData.Dataset;
ds = ds.addElement(u1);   % -> ω_ref
ds = ds.addElement(u2);   % -> λ_ref

simIn = simIn.setExternalInput(ds);

outSim = sim(simIn);
