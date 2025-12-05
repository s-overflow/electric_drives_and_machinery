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

selections = [2 5];

inverted = [1 1];

fn=1;
figure(fn);

for i = 1:numel(selections)
    selection = selections(i);

    fname=fnames{selection};
    mv=load(fname);
    aux=fieldnames(mv);
    mv=getfield(mv,aux{1});
    
    t=mv.X.Data';              % s, time
    
    varef=mv.Y(1).Data';       % V, armature reference voltage
    ia=mv.Y(7).Data';          % A, armature current
    iaref=mv.Y(3).Data';       % A, armature reference current
    ie=mv.Y(8).Data';          % A, field current    
    isd=mv.Y(4).Data';         % A, flux building current component of IM
    isq=mv.Y(5).Data';         % A, torque building current component of IM
    phiel=mv.Y(6).Data';       % rad, electrical rotor position (= mech. Rotorlage*2)
    torq=mv.Y(9).Data';        % Nm, shaft torque
    vdc=mv.Y(10).Data';         % V, filtered DC-link voltage
    w=mv.Y(12).Data';          % rad/s, speed unfiltered
    wfilt=mv.Y(11).Data';      % rad/s, speed filtered
    wref=mv.Y(13).Data';       % rad/s, reference speed

    plot(t,rescale(inverted(i)*ia), 'DisplayName', compose("ia_%d", selections(i)));
    
    hold on;
end

plot(t,rescale(iaref), 'DisplayName', 'ia_{ref}');
grid on;
xlabel('time in s');
ylabel('normalized armatur current in A');
legend('Location','NorthEast');
xlim([0.4 0.6]);
ylim([-0.2 1.2]);
hold off;
