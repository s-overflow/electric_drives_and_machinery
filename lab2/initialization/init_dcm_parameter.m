% 26.10.2020 R. Seebacher
% CoEDaM 
%   Unit DC-machine, parameters
%       converter model
%       signal generator
%       mechanical system
% applicable for models: 
%           converter_PAM.xls.............dc-link converter with pulse amplitude modulation
%           converter_PWM_interlock.xls...dc-link converter with pulse width modulation and interlock
%           mechanical_system.slx.........mechanical system:
%                                         two mass oscillator, incremental encoder and speed filter
%
% dc-machine parameters and total inertia are example parameters, to be
% replaced by your measurements !
% feel free to determine additional parameters by appropriate tests during laboratory 
%       
% sections:
%
%   constant
%   converter
%   measurement
%   dc-machine              replace parameters by your measurements!
%   mechanical system       replace total inertia by your measurement!
%                           based on your measurements introduce Tfric(wmech) 
%                           the sum of frictional- and loss torque as a function of speed
%                           
%   reference voltage
%

%% constant
Ts=0.1993e-3;                      % s, switching period and sampling period of controller

%% converter
converter.Tsw=Ts;               % s, switching period
converter.VDC=120;              % V, constant DC-link voltage
converter.pwm.Ts=converter.Tsw; % s, period for pulse width modulation
                                %    has to be equal to switching period
converter.pwm.ti=4e-6;          % s, interlock time
converter.pwm.dmax=1-2*converter.pwm.ti/converter.pwm.Ts; % 1, dmax<= Ts-2*ti, necessary condition for pwm s-function varhit2tv.m
converter.pwm.dmin=2*converter.pwm.ti/converter.pwm.Ts;   % 1, 2*ti <= dmin, necessary condition for pwm s-function varhit2tv.m


converter.HB.Ron=15e-3;         % Ohm, on-resistance of IGBT
converter.HB.Rd=14.2e-3;        % Ohm, on-resistance of diode
converter.HB.C=10e-9;           % F, output capacitor of half bridges

aux=load('FD_mess121126_r40');  % measured forward voltage drop of diode
converter.HB.diode.ud=aux.uFD;  % V 
converter.HB.diode.id=aux.iFD;  % A

aux=load('ES_mess121126_r46');  % measured forward voltage drop of IGBT
converter.HB.igbt.ud=aux.uES;   % V
converter.HB.igbt.id=aux.iES;   % A

converter.HB.u0=converter.VDC/2;% V, initial condition for half bridge output voltage

converter.HB1=converter.HB;     % 1, half bridge 1
converter.HB2=converter.HB;     % 1, half bridge 2

%% measurement
% Fluke N5000 power analyser
N5000.Tm=100*Ts;                    % s, averaging period, minimum 20 ms, for simplicity an integer multiple of Ts was chosen
N5000.Ts=1/1000e3;                  % s, sampling period (in reality it is 1024 kS/s, for simplicity 1000 kS/S were chosen, integer multiple of Ts)
[N5000.AAF.b N5000.AAF.a]=butter(2,2*pi*180e3,'s'); % assumption for the filter coefficients of N5000 antialiasing filter
                                                    % the only available information is : -3dB at 180 kHz       %
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
                                                    
                                                    

%% dc-machine
% example parameters, in the neighbourhood of real parameters 
dcm.Ra=0.6115;     % Ohm, armature resistance                          replace value by your measurement ! 
dcm.La=1.419e-3;  % H, armature inductance                            replace value by your measurement !
dcm.emf=0;      % V, constant back emf, auxiliary variable for test purposes
dcm.ia0=0;      % A, armature current, initial condition

dcm.KPhi_tab=[0.1231 0.1759 0.2143 0.2370 0.2452 0.2523 0.2585 0.2640 0.2731]';  % Vs, K*Phi vector,         replace values by your measurements !
dcm.if_tab=[0.210 0.310 0.412 0.513 0.563 0.614 0.664 0.715 0.815]';        % A, field current vector,  replace values by your measurements !
dcm.Rf=117;     % Ohm, resistance of field winding

% field winding induction  %Lf(if,ia)*if lookup table
dcm.psiftab = [0 3.1250 6.1865 9.1365 11.8518 14.0125 15.4040 16.3725 17.1616 17.8596];
dcm.iftab = 0:0.08:0.72;
dcm.psie0 = 0;

% selects which model is used
use_nonlin_model = 0;

%% mechanical system
% two rigid bodies (Idcm and Iim) elastically coupled
shaft.Tfric=0.29;                      % Nms, sum of frictional and loss torque as a function of speed
                                    %                               based on your measurements introduce Tfric(wmech) ! 
                                    % split up Tfric to T_fric_dcm and T_fric_im
shaft.Itotal=0.0168;                 % kgm^2, total moment of inertia, replace value by your measurement !

shaft.I1=shaft.Itotal*(1-.22);      % kgm^2, moment of inertia of dcm and coupling
shaft.I2=shaft.Itotal-shaft.I1;     % kgm^2, moment of inertia of im and coupling
shaft.k=0.005;    % Nms/rad, damping coefficient
shaft.c=2*955;    % Nm/rad, elasticity
shaft.w1_0=0;     % rad/s, initial condition, dcm rotor speed  
shaft.phi1_0=0;   % rad, initial condition, dcm rotor position
shaft.dw_0=0;     % rad/s, initial condition of angular difference speed dw=w1-w2
shaft.dphi_0=0;   % rad, initial condition of difference position  dphi=phi1-phi2
 


save("dcm_meas_params.mat", "dcm", "shaft");

%% reference voltage
% reference voltage may consist of three parts
% vref=v_const + v_alternating + v_pulse
%
% sections of constant voltage with rate limited transitions
vref.const.times=[0 1 3];                   % s, step times 
                                            % as many steps will be summed up as entries in this vector appear
                                            % Sizes of times, v0s and vrefs have to be equal !
vref.const.v0s=[0 0 0];                     % V, initial condition for the steps
vref.const.vrefs=[21 -42 21]*1;             % V, step values
vref.Ts=Ts;                                 % s, sampling period for signal generator
                                            % given example:  vref starts at 0, at t=0 vref goes up with slope 15V/s to 15V
                                            %                                   at t=1 vref goes down with slope -15 V/s to -15 V
                                            %                                   at t=3 vref goes up with slope 15 V/s to 0 V
vref.const.rl.Ts=Ts;                        % s, sampling period for rate limiter
vref.const.rl.slope=21;                     % V/s, maximum slope  |v(k*Ts)-v((k-1)*Ts)|<=slope*Ts
vref.const.rl.y0=vref.const.v0s(1);         % V, initial condition of rate limiter

% alternating voltage
vref.alt.times=[0 .5];                      % s, step times
% vref.alt.v0s=[0 0];                         % V, initial condition of amplitude steps
vref.alt.amplitudes=[4 -4]*0;               % V, step values of amplitude
vref.alt.frequency=200;                     % Hz, frequency

% voltage pulse
vref.pulse.times=[0 1];                     % s, step times
vref.pulse.v0s=[0 0];                       % V, initial condition of steps
vref.pulse.vrefs=[5 -5]*0;                  % V, step values
vref.Ts=Ts;                                 % s, sampling period for pulse generator 


use_nonlin_model = 0;