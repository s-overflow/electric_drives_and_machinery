fnames={'exp001'
        'exp002' 
        'exp003'        
        'exp004' 
        'exp005'
        'exp006'        
        'exp007'
        'exp008'
        'exp009'
        'exp010'
        'exp011'
        'exp012'  
        'exp013'  
        };    

selections = [3 5];

inverted = [1 1];
offset = [0 0];
additional_text = ["" ""];

fn=1;
figure(fn);

for i = 1:numel(selections)
    selection = selections(i);

    fname="measurements/" + fnames{selection};
    mv=load(fname);
    aux=fieldnames(mv);
    mv=getfield(mv,aux{1});
    
    t=mv.X.Data';              % s, time

    isq=mv.Y(12).Data';         % A, torque building current component of IM
    

    nfilt = wfilt / (2 * pi) * 60 + offset(i);
    nref = wref / (2 * pi) * 60;

    plot(t, isq, 'DisplayName', compose("i_{Sq %d}%s", selections(i), additional_text(i)));
    
    hold on;
end

% plot(t,wref, 'DisplayName', 'n_{ref}');
grid on;
xlabel('time in s');
ylabel('torque building current i_{Sq} in A');
legend('Location','SouthEast');
xlim([0.95 1.1]);
% ylim([-0.2 1.2]);
hold off;
