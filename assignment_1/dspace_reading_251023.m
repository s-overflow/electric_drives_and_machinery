% 23.10.2025 R. Seebacher
% CoEDaM WS25/26
% DCM-Parameter
%

fnames={'coast_stop_ie06A'       %  1, coast down with ie=0.6 A
        'resistance'     %  2, slow ramp |d(va)/dt|=2V/s, 21.75 V -> -21.75 V -> 0 V, ie=0 A, rotor is not locked
    
        
};
%     
%     
%    
wahl=2;

fname=fnames{wahl};
mw=load(fname);
aux=fieldnames(mw);
mw=getfield(mw,aux{1});

% measurands: v_aref v_eref delta_phi_el phi_el i_a i_e torque V_dc duty1 duty2 V_dcfiltered w_raw w_filtered
% unit         V      V       rad          rad   A  A   Nm    V    1    1      V           rad/s   rad/s     %                
% Nr.:         1     2        3            4     5  6   7     8    9    10     11           12     13        %

td=mw.X.Data';           % s, Zeit

% for z=1:length(mw.Y) disp([num2str(z) ' ' mw.Y(z).Path '/' mw.Y(z).Name]);end
% 1 Model Root/mr/DCM/va_ref
% 2 Model Root/mr/DCM/ve_ref
% 3 Model Root/mr/IO/dpos2dphi_el/Out1
% 4 Model Root/mr/IO/phielectrical1/phi
% 5 Model Root/mr/IO/scale1/dcm_ia
% 6 Model Root/mr/IO/scale1/dcm_ie
% 7 Model Root/mr/IO/scale1/torque
% 8 Model Root/mr/IO/scale1/vdc
% 9 Model Root/mr/IO/v_2_d_cnvB/d1_B
% 10 Model Root/mr/IO/v_2_d_cnvB/d2_B
% 11 Model Root/mr/IO/vdc_filter1/Out1
% 12 Model Root/mr/IO/w/Out1
% 13 Model Root/mr/IO/w_filter/Out1

% the suffix "d" denotes the source dSpace 
v_arefd=mw.Y(1).Data';       % V, armature voltage, reference value
v_erefd=mw.Y(2).Data';       % V,excitation voltage, reference value
delta_phi_eld=mw.Y(3).Data'; % rad, increment in electrical rotor position
phi_eld=mw.Y(4).Data';       % rad, electrical rotorposition (= mech. rotorposition*2)
i_ad=mw.Y(5).Data';           % A, armature current
i_ed=mw.Y(6).Data';           % A, field current    
T_d=mw.Y(7).Data';            % Nm. shaft torque (torque transducer)
v_dcd=mw.Y(8).Data';          % V, DC-link voltage
d_1d=mw.Y(9).Data';           % 1, duty cycle of half bridge 1
d_2d=mw.Y(10).Data';          % 1, duty cycle of half bridge 2
v_dcfd=mw.Y(11).Data';        % V, filtered DC-link voltage
w_d=mw.Y(12).Data';           % rad/s, mech. rotorspeed
w_filtd=mw.Y(13).Data';       % rad/s, mech. rotorspeed filtered

fn=1;
figure(fn);
plot(td,i_ad);
grid on;
xlabel('time in s');
ylabel('armature current in A');

fn=fn+1;
figure(fn);
plot(td,T_d);
grid on;
xlabel('time in s');
ylabel('shaft torque in Nm');

fn=fn+1;
figure(fn);
plot(td,phi_eld*180/pi);
grid on;
xlabel('time in s');
ylabel('el. rotorposition in deg');


fn=fn+1;
figure(fn);
plot(i_ad,v_arefd);
grid on;
xlabel('i_{a} in A');
ylabel('v_{aref} in V');


fn=fn+1;
figure(fn);
plot(td,w_filtd);
grid on;
xlabel('time in s');
ylabel('w_{filt} in rad/s');

fn=fn+1;
figure(fn);
plot(td,w_filtd*30/pi);
grid on;
xlabel('time in s');
ylabel('n_{filt} in rpm');


fn=fn+1;
figure(fn);
plot(td,i_ed);
grid on;
xlabel('time in s');
ylabel('field current in A');

fn=fn+1;
figure(fn);
plot(td,v_dcd);
grid on;
xlabel('time in s');
ylabel('DC-link voltage in V');