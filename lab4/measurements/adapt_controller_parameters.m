% 16.1.2026 R. Seebacher
%
% CoEDaM
%   IM control
%   Adaptation of provided controller parameters to laboratory structure
%
%
% -------------------Preconditions --------------------------------------------------
%
% Ts=200e-6;   s, sampling period
% fc=20;      Hz, cut off frequency of speed filter, first order low pass
% is_max=28;   A, maximum stator current amplitude
% vs_max=120/2;  V, maximum stator voltage amplitude
%
% PI controller
%  [b1*z+b0]/(z-1) = b1*[1+(b1+b0)/b1*1/(z-1)]= k*(1 + Ts/T*1/(z-1)]
%   => k=b1
%   => T=Ts*b1/(b1+b0)
%
%  Back calculation according to Hanus conditioning technique
%  u(k)...actuating signal at t=k*Ts, k=0,1,2....
%  u_sat(k)...saturated actuating signal
%  e(k)...control error
%  e_sat(k)...adapted control error that fits to u_sat(k)
%  i(k)...integrator output
%
%       u(k)=k*(e(k)+i(k))
%       u_sat(k)=k*(e_sat(k)+i(k))
%          =>   e_sat(k)=(u_sat(k)-u(k))/k+e(k)
%       i(k+1)=i(k)+Ts/T*e(k)-Ts/T*(u(k)-u_sat(k))/k  
%          =>   kb=Ts/(T*k)
%
% --------------------Required structure -------------------------------------------- 
%
% current controller
% ctrl.i.Ts     double, sampling period
% ctrl.i.k      double, gain
% ctrl.i.T      double, integrator time constant
% ctrl.i.kb     double, back calculation coefficient
% ctrl.i.name   string, identfification
%
% flux controller
% ctrl.lambdar.Ts     double, sampling period
% ctrl.lambdar.k      double, gain
% ctrl.lambdar.T      double, integrator time constant
% ctrl.lambdar.kb     double, back calculation coefficient
% ctrl.lambdar.name   string, identfification
%
% flux observer
% ctrl.observer.Rr    double, rotor resistance
% ctrl.lambdar.Lm     double, magnetising inductance
% ctrl.lambdar.Lsigs  double, stator leakage inductance
% ctrl.lambdar.Lsigr  double, rotor leakage inductance

% speed controller
% ctrl.w.Ts     double, sampling period
% ctrl.w.k      double, gain
% ctrl.w.T      double, integrator time constant
% ctrl.w.kb     double, back calculation coefficient
% ctrl.w.name   string, identfification
%

%% user settings
user.save=1;
user.author='Meinhart_Polt_20260120_wneu';
user.filename= user.author; %'unintentionally'; % user.author;


%% provided data
% Email from Mr. Meinhart 20.1.2026
%load ourParams_altBackCalc.mat;
%load propParamAddendum.mat;
%load Ts_richtig.mat;
load w_neu.mat;



%% ad identifier and smapling period
ctrl.i.Ts=200e-6;
ctrl.i.name=user.author;

% speed controller
ctrl.w.Ts=ctrl.i.Ts;
ctrl.w.name=user.author;

% flux controller
ctrl.lambdar.Ts=ctrl.i.Ts;
ctrl.lambdar.name=user.author;

% observer, email Meinhart 20.1.2026
% Rs = 0.1995; % Stator resistance [Ohm]
% Rr = 0.0851; % Rotor resistance [Ohm]
% % Inductances
% LsigmaS = 402.4e-6; % Stator leakage inductance [H]
% LsigmaR_ = 402.4e-6; % Rotor leakage inductance [H] LsigmaR'
% Lm = 5.685e-3; % Magnetising inductance [H] 


ctrl.observer.Rr=0.0851;
ctrl.observer.Lsigs=402.4e-6;
ctrl.observer.Lsigr=402.4e-6;
ctrl.observer.Lm=5.685e-3;





ctrl.observer.name=user.author;


%% save data
if user.save
    save(user.filename,'ctrl');
end    







