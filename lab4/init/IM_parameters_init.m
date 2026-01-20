clear all
clc
close all

Ts = 200*1e-6;   % switching period and sampling period of controller

s=tf('s');

% use either our measured parameters or the ones from the addendum
use_measured_params = 1;

%% IM parameters (assignment sheet)

% Electrical resistances
if(use_measured_params)
    Rs = 0.1995;        % Stator resistance [Ohm] 
    Rr = 0.0851;        % Rotor resistance  [Ohm] 
    
    % Inductances
    LsigmaS = 402.4e-6;  % Stator leakage inductance [H] 
    LsigmaR_ = 402.4e-6; % Rotor leakage inductance  [H] LsigmaR'
    Lm = 5.685e-3;       % Magnetising inductance    [H]
else % from lab addendum
    Rs = 0.149;        % Stator resistance [Ohm] 
    Rr = 0.103;        % Rotor resistance  [Ohm] 
    
    % Inductances
    LsigmaS = 3.43e-4;  % Stator leakage inductance [H] 
    LsigmaR_ = 5.00e-4; % Rotor leakage inductance  [H] LsigmaR'
    Lm = 8.27e-3;       % Magnetising inductance    [H]
end
% convenience; 
Ls = LsigmaS + Lm;              % Ass Sheet (5)
Lr = LsigmaR_ + Lm;
L_sigma = (Ls - Lm^2/Lr);       % (3.15) unter satz
R_sigma = (Rs + Rr*(Lm/Lr)^2);  % (3.19)
Tau_sigma = L_sigma/R_sigma;    % (3.24) darunter
Tau_R = Lr/Rr;                  % (3.26)

% Clarke transform
im.T = (2/3) * [ 1      -0.5      -0.5;
              0   sqrt(3)/2  -sqrt(3)/2 ];
    
im.ET = [ 1       0;
         -0.5   sqrt(3)/2;
         -0.5  -sqrt(3)/2 ];


J = 0.0168;         % inertia
p = 2;              % pole pairs

par.Ts = Ts;
par.p = p;
par.J = J;
par.Ls = Ls;
par.Lr = Lr;
par.Lm = Lm;
par.Rs = Rs;
par.Rr = Rr;
par.is_max = 30;
par.k_is = 0.8;


busInfo = Simulink.Bus.createObject(par);



%%
% Incremental encoder
incenc.Ts=Ts;       % s, sampling period
incenc.S=2500;      % 1, lines (Strichzahl)
incenc.A=4;         % 1, resolution inbetween lines, e.g. quadrature encoder A=4
incenc.phiz0=0;     % rounds, initial mechanical position in rounds, phi(0)/(2*pi)

% speed filter
% first order Butterworth low pass represents the solution of 
% d(y)/dt=1/tau*(x-y) with trapezoidal rule
% y(k)=y(k-1)+Ts/2*(d(y)/dt(k)+d(y)/dt(k-1))
% y(k)=y(k-1)+Ts/(2*tau)*[x(k)-y(k)+x(k-1)-y(k-1)]
% y(k)*[1+Ts/(2*tau)]=y(k-1)*[1-Ts/(2*tau)]+Ts/(2*tau)*[x(k)+x(k-1)];
% 
Fw.Ts=Ts;
Fw.fg=20; % Hz, corner frequency
Fw.tau=1/(2*pi*Fw.fg);
Fw.V=Fw.Ts/(2*Fw.tau)/(1+Fw.Ts/(2*Fw.tau));
Fw.w0=0; % rad/s, initial condition, but at t=t(0)-k*Ts         

%% limits
% TODO: use actual current and voltage limits
im.vDC = 124;   % V
im.imax = 21.4; % A
im.wmax = 4265*30/pi;   % 1/s

%% Plant transfer function

G_iv_s = 1/R_sigma * 1/(Tau_sigma*s + 1);
F_lambdai_s = Lm / (s*Tau_R + 1);           % flux  model
G_h_s = F_lambdai_s;                        % actual flux relation

%% controller

lambda_Rd_ref = 0.08; % [Vs] constant


if(~exist('ctrl', 'var'))
    try
        if(use_measured_params)
            load("../tuned_controllers/our_params.mat")
            disp("Loaded controller for measured parameters from lab3")
        else
            load("../tuned_controllers/rs_approved.mat")
            disp("Loaded controller for proposed parameters from addendum")
        end
    catch
        warning("init script not called from its directory, controllers are not not being loaded")
    end
end
    
en = 1;         % enable controllers
im.iSmax = 30;     % max current space vector
im.vSmax = 55;     % max voltage space vector