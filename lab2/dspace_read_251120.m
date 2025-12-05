% 20.11.2025 R. Seebacher
% CoEDaM WS25/26
% DCM-Control, show measurements
%
%

%% data pool

fnames={'exp01'
        'exp02' 
        'exp03'        
        'exp04' 
        'exp05'
        'exp06'        
        'exp07'
        'exp08'
        'exp09'
        'exp10'
        'exp11'        
        };    

%% load data
selection=2;           % pick out one of the experiments listed in fnames

fname=fnames{selection};
mv=load(fname);
aux=fieldnames(mv);
mv=getfield(mv,aux{1});

%% assign variables

% for z=1:length(mv.Y) disp([num2str(z) ' ' mv.Y(z).Path '/' mv.Y(z).Name]); end
% 
% available:
% Nr.   Quantity
% 1 Model Root/mr/DCM/ia_controller/va_ref
% 2 Model Root/mr/DCM/speed_controller/I/Out1
% 3 Model Root/mr/DCM/sw_ia_ref/Out1
% 4 Model Root/mr/IM/Observer/isd
% 5 Model Root/mr/IM/Observer/isq
% 6 Model Root/mr/IO/phielectrical1/phi
% 7 Model Root/mr/IO/scale1/dcm_ia
% 8 Model Root/mr/IO/scale1/dcm_ie
% 9 Model Root/mr/IO/scale1/torque
% 10 Model Root/mr/IO/vdc_filter1/Out1
% 11 Model Root/mr/IO/w_filter/Out1
% 12 Model Root/mr/IO/w/Out1
% 13 Model Root/mr/wref/wref

t=mv.X.Data';              % s, time

varef=mv.Y(1).Data';       % V, armature reference voltage
ia=mv.Y(7).Data';          % A, armature current
iaref=mv.Y(3).Data';       % A, armature reference current
ie=mv.Y(8).Data';          % A, field current    
isd=mv.Y(4).Data';         % A, flux building current component of IM
isq=mv.Y(5).Data';         % A, torque building current component of IM
phiel=mv.Y(6).Data';       % rad, electrical rotor position (= mech. Rotorlage*2)
torq=mv.Y(9).Data';        % Nm, shaft torque
vdc=mv.Y(10).Data';        % V, filtered DC-link voltage
w=mv.Y(12).Data';          % rad/s, speed unfiltered
wfilt=mv.Y(11).Data';      % rad/s, speed filtered
wref=mv.Y(13).Data';       % rad/s, reference speed



%% presentation
% 
fn=1;
figure(fn);
plot(t,iaref,t,ia);
grid on;
xlabel('time in s');
ylabel('armatur current in A');
legend('ia_{ref}','ia','Location','NorthEast');
xlim([0.4 0.6]);
% ylim([-0.2 1.2]);


% fn=fn+1;
% figure(fn);
% plot(t,torq);
% grid on;
% xlabel('time in s');
% ylabel('torque in Nm');
% 
% fn=fn+1;
% figure(fn);
% plot(t,phiel*180/pi);
% grid on;
% xlabel('time in s');
% ylabel('el. rotorposition in deg');


fn=fn+1;
figure(fn);
plot(t,varef);
grid on;
xlabel('time in s');
ylabel('v_{a, ref} in V');
xlim([0.4 0.6]);


% fn=fn+1;
% figure(fn);
% plot(t,wref*30/pi,t,wfilt*30/pi);
% grid on;
% xlabel('time in s');
% ylabel('speed in rpm');
% legend('n_{ref}','n_{filtered}','Location','NorthEast');

% fn=fn+1;
% figure(fn);
% plot(t,isq);
% grid on;
% xlabel('time in s');
% ylabel('isq in A');
% 
% fn=fn+1;
% figure(fn);
% plot(t,vdc);
% grid on;
% xlabel('time in s');
% ylabel('vdc in V');