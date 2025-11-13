% 23.10.2025 
% REA WS25/26
% DCM-Parameter
%

%% constants
i_th=3;  % A, current threshold  (out of the nonlinear region of converter voltage drop)


fnames={'resistance'  %  1, triangular voltage curve, va_max=21.75 V, |d(va)/dt| = 2V/s, ie=0, no locked rotor
        };
    
    
   
wahl=1;

fname=fnames{wahl};
mw=load(fname);
aux=fieldnames(mw);
mw=getfield(mw,aux{1});



dspace_reading_251023;   % set "wahl" in dspace_reading to "5" to load the appropriate data file %
td=mw.X.Data';           % s, Zeit


% % Model Root/mr/GM\ua
% % Model Root/mr/IO1/PWM_out/dB1\Out1
% % Model Root/mr/IO1/PWM_out/dB2\Out1
% % Model Root/mr/IO1/PWM_out/dB3\Out1
% % Model Root/mr/IO1/phielektrisch\phi
% % Model Root/mr/IO1/scale\gm_ia
% % Model Root/mr/IO1/scale\gm_ie
% % Model Root/mr/IO1/scale\m
% % Model Root/mr/IO1/scale\u_zk
% % Model Root/mr/IO1/w\Out1
% % Model Root/mr/IO1/w_Filter\Out1
% 
% vrefd=mw.Y(1).Data';       % V, reference voltage
% phield=mw.Y(5).Data';    % rad, electrical rotorposition (= mech. rotorposition*2)
% iad=mw.Y(6).Data';       % A, armature current
% ied=mw.Y(7).Data';       % A, field current    
% Td=mw.Y(8).Data';        % Nm. shaft troque (torque transducer)
% vdcd=mw.Y(9).Data';      % V, filtered DC-link voltage
% wd=mw.Y(10).Data';        % rad/s, mech. rotorspeed
% wfiltd=mw.Y(11).Data';    % rad/s, mech. rotorspeed filtered

fn=1;
figure(fn);
plot(td,i_ad);
grid on;
title('dSpace')
xlabel('time in s');
ylabel('armature current in A');

%% N5000
mwN = mwgeigl(pwd,fname); %config-file config_La_ustep_ws2324.txt
% initialisation file: config_vrmp_60s_ws2526.txt
% SWE2:FUNC  "VOLT3:MEAN","CURR3:MEAN","VOLT6:MEAN","CURR6:MEAN","VOLT2:MEAN"
% Messgrößen:  t  ua ia   ve ie   pos
% Nr.:         1   2  3    4  5     6
iaN =mwN(:, 3);
vaN = mwN(:, 2);
tN = mwN(:, 1);

fn=2;
figure(fn);
plot(tN,iaN);
grid on;
title('N5000')
xlabel('time in s');
ylabel('armature current in A');

fn=3;
figure(fn);
plot(iaN,vaN,i_ad,v_arefd);
grid on;
xlabel('armature current in A');
ylabel('voltages in V');
legend('N5000','dSpace','Location','best');

% rough estimate of Ra and Rtotal with [xx yy]=ginput(2) applied to figure 3
% [xx yy]=ginput(2)
% Ra=diff(yy)/diff(xx)  uaN in dependence on iaN
% [xx yy]=ginput(2)
% Rtot=diff(yy)/diff(xx)  uad in dependence on iad

% magnitudes
% N5000
iaNs=abs(iaN);
[iaNs index]=sort(iaNs);
vaNs=abs(vaN(index));

% dSpace
iads=abs(i_ad);
[iads index]=sort(iads);
vrefds=abs(v_arefd(index));

% find the currents gerater than i_th for N5000 values
index=find(iaNs>i_th);
% best fit line
gN=polyfit(iaNs(index),vaNs(index),1);


% find the currents gerater than i_th for dSpace values
index=find(iads>i_th);
% best fit line
gd=polyfit(iads(index),vrefds(index),1);

Ra=gN(1);
R_total=gd(1);









fn=4;
figure(fn);
plot(iaN,vaN,iaN,gN(1)*iaN+sign(iaN)*gN(2),i_ad,v_arefd,i_ad,gd(1)*i_ad+sign(i_ad)*gd(2));
grid on;
xlabel('armature current in A');
ylabel('voltages in V');
legend('mesured','best fit','measured','best fit','Location','best');

