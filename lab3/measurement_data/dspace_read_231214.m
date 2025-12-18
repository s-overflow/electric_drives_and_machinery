% 14.12.2023 R. Seebacher
% CoEDaM WS23/24
% IM-Parameter
%

fnames={'converter_voltage_drop_90'
        'v5_imax29_ip2_90deg'     %  1, standstill, curent controlled, imax=29A |d(i)/dt|=2 A/s, phi_i=90°
        'v6_imax29_ip2_210deg'    %  2, standstill, curent controlled, imax=29A |d(i)/dt|=2 A/s, phi_i=210°
        'v7_imax29_ip2_330deg'    %  3, standstill, curent controlled, imax=29A |d(i)/dt|=2 A/s, phi_i=330°
               
        };    
   
wahl=1;

fname=fnames{wahl};
mv=load(fname);
aux=fieldnames(mv);
mv=getfield(mv,aux{1});

for z=1:length(mv.Y) disp([num2str(z) ' ' mv.Y(z).Path '/' mv.Y(z).Name]); end

% available:
% Nr.   Quantity
% 1 Model Root/mr/IO/phielectrical/phi
% 2 Model Root/mr/IO/scale/i1
% 3 Model Root/mr/IO/scale/i2
% 4 Model Root/mr/IO/scale/torque
% 5 Model Root/mr/IO/scale/vdc
% 6 Model Root/mr/IO/v_2_d_cnvA/d1_A
% 7 Model Root/mr/IO/v_2_d_cnvA/d2_A
% 8 Model Root/mr/IO/v_2_d_cnvA/d3_A
% 9 Model Root/mr/IO/vabc_sign/Out1[0]
% 10 Model Root/mr/IO/vabc_sign/Out1[1]
% 11 Model Root/mr/IO/vabc_sign/Out1[2]
% 12 Model Root/mr/IO/vdc_filter/Out1
% 13 Model Root/mr/IO/w_filter/Out1

t=mv.X.Data';           % s, Zeit

va=mv.Y(9).Data';
vb=mv.Y(10).Data';
vc=mv.Y(11).Data';
ia=mv.Y(2).Data';
ib=mv.Y(3).Data';
ic=-ia-ib; %
phiel=mv.Y(1).Data'; 
wfilt=mv.Y(13).Data';
Vdc=mv.Y(5).Data';
Vdcfilt=mv.Y(12).Data';
    
torq=mv.Y(4).Data';

da=mv.Y(6).Data';
db=mv.Y(7).Data';
dc=mv.Y(8).Data';


    
    
    T=2/3*[1 -.5 -.5
           0 sqrt(3)/2 -sqrt(3)/2
           .5 .5 .5];
       
    isS=(T*[ia ib -ia-ib]')';
    is=sqrt(isS(:,1).^2+isS(:,2).^2);
    
    phii=atan2(isS(:,2),isS(:,1));
    
    phiiu=unwrap(phii);
    gi=polyfit(t,phiiu,1);
    ws=gi(1);
    fs=ws/(2*pi)

    
    vsS=(T*[va vb vc]')';
    vs=sqrt(vsS(:,1).^2+vsS(:,2).^2);
    
    
%     nn=20;
%     bb=ones(nn,1);
%     aa=zeros(nn,1);
%     aa(1)=nn;
%     
%     vsSf=filtfilt(bb,aa,vsS);
%     vsSf=filtfilt(bb,aa,vsS);
%     
    
    
    figure(1);
    plot(t,[va vb vc]);
    grid on;
    xlabel('Time in s');
    ylabel('Stator reference voltages in V');
    legend('va','vb','vc','Location','SouthEast');
    
    
    figure(2);
    plot(t,[ia ib -(ia+ib)]);
    grid on;
    xlabel('Time in s');
    ylabel('Statorcurrents in A');
    legend('ia','ib','ic','Location','SouthEast');
    
    
    figure(3);
    plot(t,phiel);
    grid on;
    xlabel('Time in s');
    ylabel('Electr. rotorposition in rad');
    
    
    figure(4);
    plot(t,torq);
    grid on;
    xlabel('Time in s');
    ylabel('Shafttorque in Nm');
    
    figure(5);
    plot(t,Vdc,t,Vdcfilt);
    grid on;
    xlabel('Time in s');
    ylabel('Vdc in V');
    legend('unfiltered','filtered','Location','best');
    
    
    
    figure(6);
    plot(t,wfilt*30/pi);
    grid on;
    xlabel('Time in s');
    ylabel('Speed in rpm');
    
    figure(7);
    plot(ib,vb);
    grid on;
    xlabel('Time in s');
    ylabel('...');
    
    
    
    
    