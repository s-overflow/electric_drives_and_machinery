% 9.12.2025 R. Seebacher
% CoEDaM WS25/26
% IM-Parameter
%

fnames={'25A_90deg'  %  1, standstill, curent controlled, imax=25A |d(i)/dt|=2 A/s, phi_i=90°; start from 1A (by accident)
        '25A_210deg' %  2, standstill, curent controlled, imax=25A |d(i)/dt|=2 A/s, phi_i=210°
        '25A_330deg' %  3, standstill, curent controlled, imax=25A |d(i)/dt|=2 A/s, phi_i=330°             
    %  4, standstill, curent controlled, imax=25A |d(i)/dt|=2 A/s, phi_i=90°; start from 0A
        };    
   
wahl=3;

fname=fnames{wahl};
mv=load(fname);
aux=fieldnames(mv);
mv=getfield(mv,aux{1});

% for z=1:length(mv.Y) disp([num2str(z) ' ' mv.Y(z).Path '/' mv.Y(z).Name]); end
% 
% asdf

% available:
% Nr.   Quantity
% 1 Model Root/mr/IO/phielectrical1/phi
% 2 Model Root/mr/IO/scale1/im_ia
% 3 Model Root/mr/IO/scale1/im_ib
% 4 Model Root/mr/IO/scale1/im_ic
% 5 Model Root/mr/IO/scale1/torque
% 6 Model Root/mr/IO/scale1/vdc
% 7 Model Root/mr/IO/v_2_d_cnvA/d1_A
% 8 Model Root/mr/IO/v_2_d_cnvA/d2_A
% 9 Model Root/mr/IO/v_2_d_cnvA/d3_A
% 10 Model Root/mr/IO/vabc_sign/Out1[0]
% 11 Model Root/mr/IO/vabc_sign/Out1[1]
% 12 Model Root/mr/IO/vabc_sign/Out1[2]
% 13 Model Root/mr/IO/vdc_filter1/Out1
% 14 Model Root/mr/IO/w_filter/Out1
% 15 Model Root/mr/wref/wref

t=mv.X.Data';           % s, Zeit

va=mv.Y(10).Data';
vb=mv.Y(11).Data';
vc=mv.Y(12).Data';
ia=mv.Y(2).Data';
ib=mv.Y(3).Data';
ic=mv.Y(4).Data'; %
phiel=mv.Y(1).Data'; 
wfilt=mv.Y(14).Data';
Vdc=mv.Y(6).Data';
Vdcfilt=mv.Y(13).Data';
    
torq=mv.Y(5).Data';

da=mv.Y(7).Data';
db=mv.Y(8).Data';
dc=mv.Y(9).Data';



% abc -> alpha, beta
T=2/3*[1 -.5 -.5
       0 sqrt(3)/2 -sqrt(3)/2
       .5 .5 .5];

% space vector
isS=(T*[ia ib -ia-ib]')';
is=sqrt(isS(:,1).^2+isS(:,2).^2);

phii=atan2(isS(:,2),isS(:,1));

% phii and t gets overwritten in line ~160

% get stator frequency, but isnt used?
phiiu=unwrap(phii); 
gi=polyfit(t,phiiu,1);
ws=gi(1);
fs=ws/(2*pi)

% figure(333)
% hold on
% plot(t, phiiu)
% plot(t, ws*t + gi(2))
% hold off
% legend(["phii unwrapped", "linear fit"])
% xlabel("t in s")
% ylabel("phi / rad")

vsS=(T*[va vb vc]')';
vs=sqrt(vsS(:,1).^2+vsS(:,2).^2);


%     nn=20;
%     bb=ones(nn,1);
%     aa=zeros(nn,1);
%     plot(plplaa(1)=nn;
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


% figure(3);
% plot(t,phiel);
% grid on;
% xlabel('Time in s');
% ylabel('Electr. rotorposition in rad');


% figure(4);
% plot(t,torq);
% grid on;
% xlabel('Time in s');
% ylabel('Shafttorque in Nm');

figure(5);
plot(t,Vdc,t,Vdcfilt);
grid on;
xlabel('Time in s');
ylabel('Vdc in V');
legend('unfiltered','filtered','Location','best');



% figure(6);
% plot(t,wfilt*30/pi);
% grid on;
% xlabel('Time in s');
% ylabel('Speed in rpm');

%% get viref_per_ii dSpace data
% vabc_ref = [va vb vc];
% iabc_ref = [ia ib ic];
% 
% sel = mod(wahl,3) + 1;
% vi_ref = vabc_ref(:, sel);
% i_sel = iabc_ref(:, sel);
% 
% i_threshold = 5;
% vir_lin1 = vi_ref(i_sel > i_threshold);
% i_lin1 = i_sel(i_sel > i_threshold);
% p1=polyfit(i_lin1,vir_lin1,1);
% 
% vir_lin2 = vi_ref(i_sel < -i_threshold);
% i_lin2 = i_sel(i_sel < -i_threshold);
% p2=polyfit(i_lin2,vir_lin2,1);
% 
% gradients = [p1(1), p2(1)];
% pg_diff = diff(gradients)
% allowed_diff = 1e-2;
% if(max(abs(pg_diff)) > allowed_diff)
%     warning("vi_ref fit: max gradient diff: " + max(abs(pg_diff)) + " > " +allowed_diff);
% end
% 
% switch wahl
%     % ia = 0, sel = b
%     case 1
%        vbref_per_ib = mean(gradients);
%        save("cvd_calc.mat", "vbref_per_ib");
%     % ib = 0, sel = c
%     case 2
%         vcref_per_ic = mean(gradients);
%         save("cvd_calc.mat", "vcref_per_ic", "-append");
%     % ic = 0, sel = a
%     case 3
%         varef_per_ia = mean(gradients);
%         save("cvd_calc.mat", "varef_per_ia", "-append");
% end
% 
% i_help = min(i_sel):1:max(i_sel);
% figure(7),clf;
% hold on
% plot(i_sel,vi_ref);
% plot(i_lin1, p1(1)*i_lin1 + p1(2),"--", "LineWidth",1.3)
% plot(i_lin2, p2(1)*i_lin2 + p2(2),"--", "LineWidth",1.3)
% plot(i_help, mean(gradients)*i_help,"-.", "LineWidth",1.3)
% hold off
% grid on;
% legend(["measured", "linear region+ fit", "linear region- fit", "mean fit gradient"])
% xlabel('i-ref in A');
% ylabel('vi-ref in V');
    
    %% N5000 Messwerte
    mw=mwgeigl(pwd,fname);
    % config: config_am_innenwiderstand_90deg_191209.txt, config_am_innenwiderstand_210deg_191209.txt und  config_am_innenwiderstand_330deg_191209.txt
    %                 "VOLT2:MEAN","VOLT3:MEAN","VOLT5:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR5:MEAN"
    % Messgrößen:  t  FUNC  "VOLT2:MEAN","VOLT3:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR6:MEAN","VOLT5:MEAN"
    %                 Zeit   ua        ub           uc            ia           ib            ic       ustern-uzk_minus 
    % Nr.:         1         2          3            4           5              6            7             8    %
    t=mw(:,1);
    t=t-t(1);
    
    uabc=mw(:,[2 3 4]);   % V, Strangspannungen
    u0=mw(:,8);           % V, Spannung Sternpunkt gegen Uzk_Minus
    iabc=mw(:,[5 6 7]);   % A, Strangströme
    
    Tn=mean(diff(t));                     % s, mittlere Abtastperiode N5000
    isS=(T*iabc')';                       % A, Statorstromraumzeiger
    is=sqrt(isS(:,1).^2+isS(:,2).^2);     % A, Betrag des Statorstromraumzeigers
    
    phii=atan2(isS(:,2),isS(:,1));        % rad, Winkel des Statorstromraumzeigers
    
    
    % Darstellung ohne Berücksichtigung der Spannung zwischen Sternpunkt und Uzk-minus
    % Das stimmt sehr gut mit der Auswertung durch
    % aw_AMPara_Innenwiderstand.m überein.
    switch wahl
        case 1
            figure(8); % wahl=1 mit phi 90°  ib, ic
            plot(ib,vb, iabc(:,2), uabc(:,2));
            grid on;
            title('Strang b');
            xlabel('Strom in A');
            ylabel('Spannung in V');
            legend('vb_{ref}','vb_{IM}','Location','best');
        case 2
            figure(9); % wahl=2 mit phi 210° ic, ia
            plot(ic,vc, iabc(:,3), uabc(:,3));
            grid on;
            title('Strang c');
            xlabel('Strom in A');
            ylabel('Spannung in V');
            legend('vc_{ref}','vc_{IM}','Location','best');
        case 3
            figure(10); % wahl=3 mit phi 330°  ia, ib
            plot(ia,va, iabc(:,1), uabc(:,1));
            grid on;
            title('Strang a');
            xlabel('Strom in A');
            ylabel('Spannung in V');
            legend('va_{ref}','va_{IM}','Location','best');
        case 4
            figure(8); % wahl=1 mit phi 90°  ib, ic
            plot(ib,vb, iabc(:,2), uabc(:,2));
            grid on;
            title('Strang b');
            xlabel('Strom in A');
            ylabel('Spannung in V');
            legend('vb_{ref}','vb_{IM}','Location','best');
        otherwise
            error('unknown "wahl" value');
    end;
    
    
%% get vi_per_ii and v0_per_i N5000 data
sel = mod(wahl,3) + 1;
vi = uabc(:, sel);
i_sel = iabc(:, sel);

i_threshold = 5;
vir_lin1 = vi(i_sel > i_threshold);
i_lin1 = i_sel(i_sel > i_threshold);
p1=polyfit(i_lin1,vir_lin1,1);

vir_lin2 = vi(i_sel < -i_threshold);
i_lin2 = i_sel(i_sel < -i_threshold);
p2=polyfit(i_lin2,vir_lin2,1);

gradients_IM = [p1(1), p2(1)];
pg_diff_IM = diff(gradients_IM)
allowed_diff = 1e-2;
if(max(abs(pg_diff_IM)) > allowed_diff)
    warning("vi_IM fit: max gradient diff: " + max(abs(pg_diff_IM)) + " > " +allowed_diff);
end

p02 = polyfit(i_sel,vi,1);
gradients_0 = p02(1);
pg_diff_0 = diff(gradients_0)
if(max(abs(pg_diff_0)) > allowed_diff)
    warning("vi_0 fit: max gradient diff: " + max(abs(pg_diff_0)) + " > " +allowed_diff);
end

switch wahl
    % ia = 0, sel = b
    case 1
       vb_per_ib = mean(gradients_IM);
       v0_per_ib = mean(gradients_0);
       save("cvd_calc.mat", "vb_per_ib","v0_per_ib", "-append");
    % ib = 0, sel = c
    case 2
        vc_per_ic = mean(gradients_IM);
        v0_per_ic = mean(gradients_0);
        save("cvd_calc.mat", "vc_per_ic","v0_per_ic","-append");
    % ic = 0, sel = a
    case 3
        va_per_ia = mean(gradients_IM);
        v0_per_ia = mean(gradients_0);
        save("cvd_calc.mat", "va_per_ia","v0_per_ia", "-append");
end

phases_str = ["a", "b", "c"];
i_help = min(i_sel):1:max(i_sel);
figure(20),clf;
hold on
plot(i_sel,vi);
plot(i_lin1, p1(1)*i_lin1 + p1(2),"--", "LineWidth",1.3)
plot(i_lin2, p2(1)*i_lin2 + p2(2),"--", "LineWidth",1.3)
plot(i_help, mean(gradients_IM)*i_help,"-.", "LineWidth",1.3)
hold off
grid on;
legend(["measured", "linear region+ fit", "linear region- fit", "mean fit gradient"])
xlabel('ii in A');
ylabel('vi-IM in V');
title("Phase "+ phases_str(sel))

figure(21),clf;
hold on
plot(i_sel,vi);
plot(i_help, mean(gradients_0)*i_help,"-.", "LineWidth",1.3)
hold off
grid on;
legend(["measured", "mean fit gradient"])
xlabel('ii in A');
ylabel('vi-0 in V');
title("Star point voltage for measurement "+ phases_str(sel))

%% calc Rcnv
clear
clc

load cvd_calc.mat

v0_per_i = [v0_per_ia; v0_per_ib; v0_per_ic];
vIM_per_i = [va_per_ia; vb_per_ib; vc_per_ic];
vref_per_i = [varef_per_ia; vbref_per_ib; vcref_per_ic];

Rcnv_vec = vref_per_i - v0_per_i - vIM_per_i;
Rcnv = diag(Rcnv_vec);

save("cvd_calc.mat", "Rcnv", "-append");