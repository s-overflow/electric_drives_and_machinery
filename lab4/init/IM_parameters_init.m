clear all
clc
close all

Ts = 200*1e-9;

s=tf('s');

%% IM parameters (assignment sheet)

% Electrical resistances
Rs = 0.149;        % Stator resistance [Ohm] 
Rr = 0.103;        % Rotor resistance  [Ohm] 

% Inductances
LsigmaS = 3.43e-4;  % Stator leakage inductance [H] 
LsigmaR_ = 5.00e-4; % Rotor leakage inductance  [H] LsigmaR'
Lm = 8.27e-3;       % Magnetising inductance    [H]

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

%% limits
% TODO: use actual current and voltage limits
im.vDC = 124;   % V
im.imax = 21.4; % A
im.wmax = 4265*30/pi;   % 1/s

%% Plant transfer function

G_iv_s = 1/R_sigma * 1/(Tau_sigma*s + 1);
G_lambdai_s = Lm / (s*Tau_R + 1);


%% controller gains
if(~exist('ctrl', 'var'))
    load("../tuned_controllers/std_controllers.mat")
    disp("Loaded standard controller parameters")
end