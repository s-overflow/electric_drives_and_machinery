%14.12.2023 Gr. 14h
%


fname='statorR.txt';


mw=load(fname);

% config: config_IM_lockedrotor_235_211210.txt
%     FUNC "VOLT2:MEAN","VOLT3:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR6:MEAN"
% hh mm ss    Ua         Ub            Uc
%  1  2  3    4           5            6           7           8           9 

U123=mw(:,[4 5 6]);
I123=mw(:,[7 8 9]);
indsNaN=find(abs(I123)<1);

R123=U123./I123;
R123_=R123;
R123_(indsNaN)=NaN;
% res=fun_grouping([U I P fs],1,0.03,5,0,100);


figure(200);
%plot(res.avg(:,2),res.avg(:,1),'-bo');
plot(R123_,'o-');
grid on; zoom on;
%%
Rtemp=R123_(:);
Rtemp(indsNaN)=[];
Rs=mean(Rtemp);

figure(201);
plot(I123,'o-');

figure(202);
plot(U123,'o-');




