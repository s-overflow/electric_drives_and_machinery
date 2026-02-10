% 2.2.2024 R. Seebacher
% CoEDaM 
%   IM-controller test
%

%% experiments
vname=[pwd '\'];
fnames={'exp001',...       %  1, DCM n = 0, IM: isd 0 -> 10 A
        'exp002',...       %  2, DCM n = 0, IM: psi_r 0 -> 0.08, both current controllers enabled and flux controller enabled
        'exp003',...       %  3, DCM: n = 0, IM: i_sq 0 -> 10A  
        'exp004',...       %  4, DCM: n = 0, IM: i_sq 10 -> 0A 
        'exp005',...       %  5, DCM: n = 1000, IM: i_sq 0 -> 10A  
        'exp006',...       %  6, DCM: n = 1000, IM: i_sq 10 -> 0A 
        'exp007',...       %  7, DCM off, IM: n = 0 -> n* = 100, i_sq should not reach current limit
        'exp008',...       %  8, DCM off, IM: n = 0 -> 1000; 
		'exp009',...       %  9, DCM: ia = 0 -> -15, IM: n = 200  ( better at n=200, to aexp_oid zero crossings of i_sqref )
        'exp010',...       %  10, DCM off, n -2000 -> 2000,  DCM-converter acts as a braking chopper, Rotorwiderstand: 85 mOhm % T limit
        'exp011',...       %  10, DCM off, n -2000 -> 2000,  DCM-converter acts as a braking chopper, Rotorwiderstand: 85 mOhm
        'exp012',...       %  10, DCM off, n -2000 -> 2000,  DCM-converter acts as a braking chopper,  % changed Rr -> 90mOhm
        'exp013',...       %  10, DCM off, n -2000 -> 2000,  DCM-converter acts as a braking chopper,  % changed Rr -> 103mOhm

        
        };

	
z=13;       % select experiment

%% load data
mw=load([vname fnames{z}]);
hilf=fieldnames(mw);
mw=getfield(mw,hilf{1});

n=length(mw.Y);


%% list of measured signals
% for z=1:length(mw.Y) disp([num2str(z) ' ' mw.Y(z).Path '/' mw.Y(z).Name]); end
%
% 15.1.2026 R. Seebacher
% 
% 1 Model Root/mr/DCM/sw_ia_ref/Out1
% 2 Model Root/mr/IM/Compensation/Lsig_d/Out1
% 3 Model Root/mr/IM/Compensation/Sum/Out1
% 4 Model Root/mr/IM/i-ctrl/id/u
% 5 Model Root/mr/IM/i-ctrl/iq/u
% 6 Model Root/mr/IM/i-ctrl/vsat/Switch2/Out1
% 7 Model Root/mr/IM/i-ctrl/vsat/Switch3/Out1
% 8 Model Root/mr/IM/Observer/al
% 9 Model Root/mr/IM/Observer/alpha
% 10 Model Root/mr/IM/Observer/alphap
% 11 Model Root/mr/IM/Observer/isd
% 12 Model Root/mr/IM/Observer/isq
% 13 Model Root/mr/IM/Observer/psir
% 14 Model Root/mr/IM/ref_distribution/isd_soll1/Out1
% 15 Model Root/mr/IM/ref_distribution/isq_soll1/Out1
% 16 Model Root/mr/IM/ref_distribution/psir_ref
% 17 Model Root/mr/IM/ref_distribution/w_ref
% 18 Model Root/mr/IO/dpos2dphi_el/Out1
% 19 Model Root/mr/IO/scale1/dcm_ia
% 20 Model Root/mr/IO/scale1/torque
% 21 Model Root/mr/IO/vdc_filter1/Out1
% 22 Model Root/mr/IO/w_filter/Out1




id_string='Model Root/mr/IM/Observer/isd';
idref_string='Model Root/mr/IM/ref_distribution/isd_soll1/Out1';
udi_string='Model Root/mr/IM/i-ctrl/id/u';
udk_string='Model Root/mr/IM/Compensation/Lsig_d/Out1';
udsat_string='Model Root/mr/IM/i-ctrl/vsat/Switch2/Out1';

iq_string='Model Root/mr/IM/Observer/isq';
iqref_string='Model Root/mr/IM/ref_distribution/isq_soll1/Out1';
uqi_string='Model Root/mr/IM/i-ctrl/iq/u';
uqk_string='Model Root/mr/IM/Compensation/Sum/Out1';
uqsat_string='Model Root/mr/IM/i-ctrl/vsat/Switch3/Out1';

psir_string='Model Root/mr/IM/Observer/psir';
psirref_string='Model Root/mr/IM/ref_distribution/psir_ref';

w_string='Model Root/mr/IO/w_filter/Out1';
wref_string='Model Root/mr/IM/ref_distribution/w_ref';

alpha_string='Model Root/mr/IM/Observer/al';
alpha_vor_string='Model Root/mr/IM/Observer/alpha';
dphi_el_string='Model Root/mr/IO/dpos2dphi_el/Out1';
alphap_string='Model Root/mr/IM/Observer/alphap';

ia_string='Model Root/mr/IO/scale1/dcm_ia';
iaref_string='Model Root/mr/DCM/sw_ia_ref/Out1';
torq_string='Model Root/mr/IO/scale1/torque';

vdc_string='Model Root/mr/IO/vdc_filter1/Out1';


%% find the index

for zz=1:n
    name=[mw.Y(zz).Path '/' mw.Y(zz).Name];
    if (strcmp(id_string,name)) id_i=zz; end;
    if (strcmp(idref_string,name)) idref_i=zz; end;
    if (strcmp(udi_string,name)) udi_i=zz; end;
    if (strcmp(udk_string,name)) udk_i=zz; end;
    if (strcmp(udsat_string,name)) udsat_i=zz; end;
    
    if (strcmp(iq_string,name)) iq_i=zz; end;
    if (strcmp(iqref_string,name)) iqref_i=zz; end;
    if (strcmp(uqi_string,name)) uqi_i=zz; end;
    if (strcmp(uqk_string,name)) uqk_i=zz; end;
    if (strcmp(uqsat_string,name)) uqsat_i=zz; end;
    
    if (strcmp(psir_string,name)) psir_i=zz; end;
    if (strcmp(psirref_string,name)) psirref_i=zz; end;
    
    if (strcmp(w_string,name)) w_i=zz; end;
    if (strcmp(wref_string,name)) wref_i=zz; end;
    
    if (strcmp(alpha_string,name)) alpha_i=zz; end;
    if (strcmp(alpha_vor_string,name)) alpha_vor_i=zz; end;
    if (strcmp(dphi_el_string,name)) dphi_el_i=zz; end;
    if (strcmp(alphap_string,name)) alphap_i=zz; end;
    
    if (strcmp(ia_string,name)) ia_i=zz; end;
    if (strcmp(iaref_string,name)) iaref_i=zz; end;
    if (strcmp(torq_string,name)) torq_i=zz; end;
    
    if (strcmp(vdc_string,name)) vdc_i=zz; end;
    
end;    

%% copy
    t=mw.X.Data;
    t=t';
    t=t-t(1);

    id=mw.Y(id_i).Data';
    idref=mw.Y(idref_i).Data';
    iq=mw.Y(iq_i).Data';
    iqref=mw.Y(iqref_i).Data';
    
    vdi=mw.Y(udi_i).Data';
    vdcomp=mw.Y(udk_i).Data';
    vdsat=mw.Y(udsat_i).Data';
    
    vqi=mw.Y(uqi_i).Data';
    vqcomp=mw.Y(uqk_i).Data';
    vqsat=mw.Y(uqsat_i).Data';
    
    lambdar=mw.Y(psir_i).Data';
    lambdar_ref=mw.Y(psirref_i).Data';
    
    w=mw.Y(w_i).Data';
    wref=mw.Y(wref_i).Data';
    
    epsilon=mw.Y(alpha_i).Data';
    epsilon_pre=mw.Y(alpha_vor_i).Data';
    dphi_el=mw.Y(dphi_el_i).Data';   
    epsilon_dot=mw.Y(alphap_i).Data'; % (d(epsilon)/dt
    
    
    ia=mw.Y(ia_i).Data';
    iaref=mw.Y(iaref_i).Data';
    torq=mw.Y(torq_i).Data';
    
    
    vdc=mw.Y(vdc_i).Data';
    
%% presentation    
    figure(1);
    plot(t,[idref id iqref iq]);
    grid on;
    xlabel('time in s');
    ylabel('stator current in A');
    legend('idref','id','iqref','iq');
    

    figure(2);
    plot(t,[vdi vdcomp vdsat]);
    grid on;
    xlabel('time in s');
    ylabel('stator voltage in V');
    legend('vdi','vdcomp','vdsat');
    
    
    
    figure(3);
    plot(t,[vqi vqcomp vqsat]);
    grid on;
    xlabel('time in s');
    ylabel('stator voltage in V');
    legend('vqi','vqcomp','vqsat');
    
    
    
    figure(4);
    plot(t,[idref/100 lambdar_ref lambdar]);
    grid on;
    xlabel('time in s');
    ylabel('isd/100 in A, rotor flux in Vs');
    legend('idref/100','lambdar_{ref}','lambdar');
      
    
    
    figure(5);
    plot(t,[wref w]*30/pi);
    grid on;
    xlabel('time in s');
    ylabel('speed in rpm');
    legend('wref','wfilter');
    
    
    figure(6);
    plot(t,[epsilon epsilon_pre]);
    grid on;
    xlabel('time in s');
    ylabel('angles in rad');
    legend('epsilon','epsilon_{pre}');
    
    figure(7);
    plot(t,ia);
    grid on;
    xlabel('time in s');
    ylabel('armature current in A');
        
    
    figure(8);
    plot(t,torq, t,smooth(torq,39));
    grid on;
    xlabel('time in s');
    ylabel('shaft torque in Nm');
    
    
    figure(9);
    plot(t,vdc);
    grid on;
    xlabel('time in s');
    ylabel('filtered DC-link voltage in V');
    
    %Ts=mean(diff(t))
    %fs=1/Ts
    
    %figure for stator current magnitude
    % figure(9);
    % plot(t, sqrt(id.^2+iq.^2));
    
    %figure for DC-link voltage
    % figure(10);
    % plot(t, vdcfilt);
    % xlabel('time in s');
    % ylabel('filtered DC-link voltage in V');
    
    