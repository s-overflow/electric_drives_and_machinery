% 3.10.2019 R.Seebacher, H.T. Eickhoff
% auxilliary function: grouping of measurements
%
% call: 
%       result=fun_grouping(mw,index,delta,minMembers,fringe,fn)
% input:
%       mw......matrix of measured values, each row is one measurement
%       index...grouping with respect to this column of mw 
%       delta...threshold for grouping (if abs(diff(mw(:,index)))<delta)
%       minMembers...a valid group consits of more or equal minMembers 
%                    measurements that fullfill the requirement
%       fringe..remove at the left and the right side fringe members of a valid group
%       fn......figure number to present grouping 
%
% output:
%       result...struct with fields
%                index
%                delta
%                minMembers
%                fringe
%                avg.....averaged values of mw for each group
%                        

function result=fun_grouping(mw,index,delta,minMembers,fringe,fn)
% 
result.index=index;
result.delta=delta;
result.minMembers=minMembers;
result.fringe=fringe;

[m,n]=size(mw);
act=mw(:,index);
diff_act=diff(act);
index=find(abs(diff_act)<delta);
indexStep=find(diff(index)>1);

avg=zeros(length(indexStep)+1,n+1);
ai=index(1);%1;
figure(fn);
hold off;
plot(act,'-bo');
xlabel('index');
ylabel('mw(:,index)');
hold on;

ids = [];
vals = [];

for z=1:length(indexStep);  % groups
    actindex=[[ai:index(indexStep(z))]'; index(indexStep(z))+1];
    length(actindex);
    %pause;
    if length(actindex)>(minMembers+2*fringe)
        actindex=actindex(fringe+1:end-fringe);
        avg(z,1:n)=mean(mw(actindex,:));
        avg(z,n+1)=1;
        plot(actindex,act(actindex),'r*');
       
        ids = [ids; actindex];
        vals = [vals; act(actindex)];
    end
    ai=index(indexStep(z)+1);
end



actindex=[ai:index(end)+1]';
if length(actindex)>(minMembers+2*fringe)
    actindex=actindex(fringe+1:end-fringe);
    avg(z+1,1:n)=mean(mw(actindex,:));
    avg(z+1,n+1)=1;
    plot(actindex,act(actindex),'r*');

    ids = [ids; actindex];
    vals = [vals; act(actindex)];
end
figure(fn);
hold off;
index=find(avg(:,n+1)==0);
avg(index,:)=[];
result.avg=avg(:,[1:end-1]);


result.ids = ids;
result.vals = vals;
