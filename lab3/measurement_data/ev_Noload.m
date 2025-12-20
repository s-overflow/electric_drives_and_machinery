% 9.12.2025
%

% R-Shunt A30b, A30d, A30f
%     Kanäle 2,   3    ,6

fname='nl_50Hz.txt';


mw=load(fname);

% config: config_IM_lockedrotor_235_211210.txt
%     FUNC "VOLT2:HAR","VOLT3:HAR","VOLT6:HAR","CURR2:HAR","CURR3:HAR","CURR6:HAR","POW2:HAR","POW3:HAR","POW6:HAR","FREQ"
% hh mm ss    Ua         Ub            Uc
%  1  2  3    4           5            6           7           8           9            10        11         12       13  %

%vom KS-Versuch
Lsigs =  3.992710335861623e-04;
Rs = 0; %Statorwiderstand

Us=mean(mw(:,[4 5 6]),2);
Is=mean(mw(:,[7 8 9]),2);

Ps=sum(mw(:,[10 11 12]),2);

fs=mw(:,13);

cphi=Ps./(3*Us.*Is);
Isc = Is.*exp(-1j*acos(cphi)); %komplexer Zeiger

figure(200);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(Is,Us,'o-');
grid on; zoom on;

figure(201);
plot(Is,Ps,'o-');
grid on; zoom on;
