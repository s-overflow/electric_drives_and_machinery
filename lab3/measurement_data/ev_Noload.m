% 9.12.2025
%

% R-Shunt A30b, A30d, A30f
%     Kanäle 2,   3    ,6

fname='nl_50Hz.txt';
mw=load(fname);

% --- Export folder
outDir = 'figures';
if ~exist(outDir, 'dir')
    mkdir(outDir);
end

% --- Helper: export a figure by number with a given name
saveFig = @(figNo, name) exportgraphics(figure(figNo), ...
    fullfile(outDir, name + ".png"), 'Resolution', 300);

% --- Known parameters (from locked rotor test etc.)
Lsigs = 0.6897e-03;   % stator leakage inductance (H)
Rs    = 0.1995;                  % stator resistance (Ohm)

% --- Read measured fundamental harmonics
Us = mean(mw(:,[4 5 6]),2);      % mean phase voltage magnitude (V)
Is = mean(mw(:,[7 8 9]),2);      % mean phase current magnitude (A)
Ps = sum(mw(:,[10 11 12]),2);    % total 3-phase active power (W)
fs = mw(:,13);                   % stator frequency (Hz)

ws = 2*pi*fs;                    % electrical angular frequency

% --- Power factor cos(phi)
cphi=Ps./(3*Us.*Is);

phi = acos(cphi);                % phase angle between U and I

% --- Complex phasors (choose Us as reference angle 0)
Vs  = Us .* exp(1j*0);           % complex voltage phasor
IsC = Is .* exp(-1j*acos(cphi)); % komplexer Zeiger

% --- No-load impedance
Znl = Vs ./ IsC;                 % complex impedance
Rnl = real(Znl);
Xnl = imag(Znl);

% --- Remove stator series elements: Rs + j*w*Lsigs
Zseries = Rs + 1j*ws*Lsigs;
Zm = Znl - Zseries;              % magnetizing branch impedance

Rm = real(Zm);
Xm = imag(Zm);

% --- Magnetizing branch admittance
Ym = 1 ./ Zm;
Gm = real(Ym);                   % conductance = 1/RFe
Bm = imag(Ym);                   % susceptance = -1/(w*Lm)

% --- Equivalent iron loss resistance RFe
RFe = 1 ./ Gm;

% --- Magnetizing inductance Lm
Lm = -1 ./ (ws .* Bm);

% --- Magnetizing voltage and currents
Vm  = abs(IsC .* Zm);            % |Vm| = |I|*|Zm|
Ife = Vm ./ RFe;                 % iron loss current
Im  = Vm ./ (ws .* Lm);          % magnetizing current (reactive part)

% --- Magnetizing flux linkage magnitude (Lambda_m)
Lambda_m = Vm ./ ws;             % because |Vm| = ws * |Lambda_m|

% ---------------- Figures + Export ----------------

figure(200); clf
plot(Is,Us,'o-');
xlabel("Stator current |Is| [A]");
ylabel("Phase voltage |Us| [V]");
grid on; zoom on;
saveFig(200, "Is_vs_Us");

figure(201); clf
plot(Is,Ps,'o-');
xlabel("Stator current |Is| [A]");
ylabel("3-phase active power Ps [W]");
grid on; zoom on;
saveFig(201, "Is_vs_Ps");

figure(202); clf
plot(Im, Lambda_m,'o-');
xlabel("Magnetizing current |Im| [A]");
ylabel("Magnetizing flux linkage |Lambda_m| [Vs]");
grid on; zoom on;
saveFig(202, "Im_vs_Lambda_m");

figure(203); clf
plot(Im, Lm,'o-');
xlabel("Magnetizing current |Im| [A]");
ylabel("Magnetizing inductance Lm [H]");
grid on; zoom on;
saveFig(203, "Im_vs_Lm");

figure(204); clf
plot(Is, RFe,'o-');
xlabel("Stator current |Is| [A]");
ylabel("Iron loss resistance RFe [Ohm]");
grid on; zoom on;
saveFig(204, "Is_vs_RFe");

% --- Reference magnetizing inductance at Lambda_m_ref = 0.08 Vs
Lambda_m_ref = 0.08;   % [Vs]

[Lambda_sorted, idx] = sort(Lambda_m);
Lm_sorted = Lm(idx);

% Remove duplicates in Lambda_sorted (keep first occurrence)
[Lambda_unique, ia] = unique(Lambda_sorted, 'stable');
Lm_unique = Lm_sorted(ia);

% Interpolate Lm at the desired reference flux linkage
Lm_ref = interp1(Lambda_unique, Lm_unique, Lambda_m_ref, 'linear', 'extrap');

disp("========== REFERENCE MAGNETIZING INDUCTANCE ==========");
fprintf("Lm_ref at Lambda_m_ref = %.3f Vs: %.6e H\n", Lambda_m_ref, Lm_ref);
