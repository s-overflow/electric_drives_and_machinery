% 14.12.2023,  R. Seebacher
% REA, AMParameter
%   Spannungsabfall am Umrichter
%
%  !!! Vom Benutzer sind die Namen der Messwertdateien im Abschnitt "Benutzerangaben" anzupassen.
%  !!!  Weiters ist eventuell die Reihenfolge der Messwerte die vom Messgerät
%       N5000 erfasst wurden im Abschnitt "N5000 Messwerte" anzupassen.
%
%
%
%   Prinzip:
%   Aufzeichnung der Sollspannungen der drei Halbbrücken (uad, ubd, ucd) und der zugehörigen
%   Strangströme (iad, ibd, icd=-iad-ibd) mit dem dSpace-System
%   (auch die Zwischenkreisspannung uzkd und einige weitere Größen werden  aufgezeichnet).
%   
%  Aufzeichnung der Spannung des Sternpunktes der Maschine gegen "Zwischenkreis Minus" (u0)
%  , der Strangspannungen (uabc) und der Strangströme (iabc) mit dem Messgerät N5000.
%
%  Ziel:   
%    Aus der Maschengleichung usoll=du+ustrang+u0 soll die Summe
%   aus Spannungsabfall am Umrichter "du" und Spannungsabfall am Strangwicklungswiderstand "ustrang"
%   bestimmt werden:
%       du+ustrang=usoll-u0
%
%  Da sich u0 aus der Sollspanung der stromlosen Halbbrücke nur sehr schlecht bestimmen lässt,
%  wird u0 mit dem N5000 gemessen.
%  Das verlangt aber, dass die Aufzeichnungen beider Messsysteme zeitlich synchronisiert werden. 
%  
% Die zeitliche Synchronisation wird durch Ausrichtung eines von beiden
% Messsystemen gemessenen Strangstromes erreicht.
% Als markante Ereignisse wird der positive- und der negative Scheitelpunkt angesehen.
% Die Zeit an der die Scheitelpunkte auftreten ist weder von einem konstanten Offset
% noch von einem konstanten Verstärkungsfehler abhängig.
%
% Die Scheitelpunkte "S1 (t1, ip1)" und "S2 (t2, ip2)"werden durch die Schnittpunkte von Ausgleichsgeraden
% bestimmt.
% Anhand der Zeitdifferenz zwischen "S1" und "S2" (t2-t1) werden die beiden Zeitbasen angeglichen (ktn).
% Anhand der Spanne zwischen "S1" und "S2" (ip1-ip2) wird die Verstärkung angeglichen (kin).
% Anhand des Mittelwertes (ip1+ip2)/2 wird der Offset abgeglichen.
% 
% Das erste Stück von "u0" (bevor die Bestromung beginnt) wird zusammen mit
% dem ersten Stück von "uzkfiltd" verwendet um die Messung der
% Zwischenkreisspanung durch das dSpace-System an die N5000- Messung anzupassen.
%
%  dSpace Messwerte werden mit einem "d" am Ende des Variablennamens gekennzeichnet.
% Da das N5000 Werte liefert die über 20ms gemittelt wurden, werden auch die dSpace
% Messwerte so gemittelt (einzige Ausnahme uzkfiltd).
%


%% Benutzerangaben

% Messwertdateien
fnames={'25A_90deg',...
        '25A_210deg',...
        '25A_330deg'};
    
% Filterung für das Auffinden der Bereiche des zuerst positiven Strangstromes
%            S1
%            ^
%        /      \
%     /           \
%---/               \              /-----------------------------------------------> t
%                     \         /
%                       \    /
%                         V
%                         S2
%      1.      2.    3.        4.
%    1. erste steigende Flanke
%    2. erste fallende Flanke
%    3. zweite fallende Flanke
%    4. zweite steigende Flanke
%
Tfbereich=100e-3; % s, Fensterbreite für gleitenden Mittelwert    

% Filterung für die Darstellung der Sychronisation
Tfdarst=2000e-3; %2000e-3;  % s, Fensterbreite für gleitenden Mittelwert

% Filterung für die Darstellung der Kennlinien
Tfkenn=200e-3; % s, Fensterbreite für gleitenden Mittelwert   
    
%% Bearbeitung
pool=[1 2 3];           % 1, Angabe der Messwertdateien die aus dem Vorrat "fnames" ausgewertet werden sollen
%pool=1;
%pool=[1 2];
gpd=zeros(length(pool),2);
gpn=zeros(length(pool),2);
gnd=zeros(length(pool),2);
gnn=zeros(length(pool),2);



for z=1:length(pool)
    wahl=pool(z);
        
    farben='bgr';
    fname=fnames{wahl};
    
    %% Konstante
    T=2/3*[1         -1/2       -1/2
        0 sqrt(3)/2 -sqrt(3)/2];
    
    phis=[90 210 330]';    % deg, mögliche Sollwinkel der Stromraumzeiger
    
    Tmn=20e-3;                % s, Mittelungsdauer, die N5000 Messwerte sind Mittelwerte über 20 ms
    
    %% N5000 Messwerte
    mw=mwgeigl(pwd,fname);
    % config: config_am_innenwiderstand_90deg_191209.txt, config_am_innenwiderstand_210deg_191209.txt und  config_am_innenwiderstand_330deg_191209.txt
    %                 "VOLT2:MEAN","VOLT3:MEAN","VOLT5:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR5:MEAN"
    % Messgrößen:  t  "VOLT2:MEAN","VOLT5:MEAN","VOLT6:MEAN","VOLT3:MEAN","CURR2:MEAN","CURR5:MEAN","CURR6:MEAN"
    %                 "VOLT2:MEAN","VOLT3:MEAN","VOLT6:MEAN","CURR2:MEAN","CURR3:MEAN","CURR6:MEAN","VOLT5:MEAN"
    %                 Zeit   ua        ub           uc     ustern-uzk_minus        ia           ib            ic   %
    % Nr.:         1         2          3            4           5                  6            7             8    %
    t=mw(:,1);
    t=t-t(1);
    
    uabc=mw(:,[2 3 4]);   % V, Strangspannungen
    u0=mw(:,8);           % V, Spannung Sternpunkt gegen Uzk_Minus
    iabc=mw(:,[5 6 7]);   % A, Strangströme
    
    Tn=mean(diff(t));                     % s, mittlere Abtastperiode N5000
    isS=(T*iabc')';                       % A, Statorstromraumzeiger
    is=sqrt(isS(:,1).^2+isS(:,2).^2);     % A, Betrag des Statorstromraumzeigers
    
    phii=atan2(isS(:,2),isS(:,1));        % rad, Winkel des Statorstromraumzeigers
    
    %% dSpace Messwerte
    mwd=load(fname);
    aux=fieldnames(mwd);
    mwd=getfield(mwd,aux{1});
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


    % Messgrößen: phiel ia  ib  ic  torq   Vdc va vb vc Vdcfilt  wfilt 
    % Nr.:         1     2   3   4   5      6   7  8  9     10    11  % 
    td=mwd.X.Data';             % s, dSpace-Zeit
    uad=mwd.Y(10).Data';       % V, Sollspannung Strang a, daraus wird das Tastverhältnis d1=uad/uzkfiltd+0.5 berechnet
    ubd=mwd.Y(11).Data';       % V, Sollspannung Strang a, daraus wird das Tastverhältnis d2=ubd/uzkfiltd+0.5 berechnet
    ucd=mwd.Y(12).Data';       % V, Sollspannung Strang a, daraus wird das Tastverhältnis d3=ucd/uzkfiltd+0.5 berechnet
    
    iad=mwd.Y(2).Data';       % A, Strangstrom a, gemessen (in der Mitte der Pulsperiode abgetastet)
    ibd=mwd.Y(3).Data';       % A, Strangstrom b, gemessen (in der Mitte der Pulsperiode abgetastet)
    icd=mwd.Y(4).Data';                    % A, Strangstrom c, aus iad+ibd+icd=0 berechnet
    
    phield=mwd.Y(1).Data';     % rad, elektrische Rotorlage (nur zur Kontrolle ob es zu einer Bewegung des Rotors gekommen ist)
    wfiltd=mwd.Y(14).Data';   % rad/s, gefilterte Rorordrehzahl (nur zur Kontrolle ob es zu einer Bewegung des Rotors gekommen ist)
    uzkd=mwd.Y(6).Data';       % V, Zwischnekreisspannung (in der Mitte der Pulsperiode abgetastet)
    uzkfiltd=mwd.Y(13).Data';   % V, gefilterte Zwischenkreisspannung
    
    md=mwd.Y(5).Data';         % Nm, Drehmoment an der Momentenmesswelle
    
    Td=mean(diff(td));             % s, mittlere Abtastperiode dSpace (Downsamplingfaktor 10)
    
    
    % Alle dSpace Messgrößen werden so gefiltert wie auch die N5000 Messgrößen durch das Messgerät N5000 gefiltert wurden.
    % Dies ist notwendig, weil die mit dem mit N5000 gemessene Sternpunktsspannung von den mit dem
    % dSpace System gemessenen Sollspannungen abgezogen werden soll
    
    nf=round(Tmn/Td);         % 1, Punktenanzahl für gleitenden Mittelwert um die Mittelung des N5000-Messgrößen über 20ms auch auf jene dSpace Messwerte
    bbf=ones(nf,1);           %    anzuwenden, die für die zeitliche Synchronisation von dSpace- und N5000 Messung herangezogen werden.
    aaf=zeros(nf,1);          %    Filterkoeffizienten bbf und aaf, gleitender Mittelwert
    aaf(1)=nf;
    % **************
    uad=filter(bbf,aaf,uad);
    ubd=filter(bbf,aaf,ubd);
    ucd=filter(bbf,aaf,ucd);
    
    iad=filter(bbf,aaf,iad);
    ibd=filter(bbf,aaf,ibd);
    icd=filter(bbf,aaf,icd);
    
    phield=filter(bbf,aaf,phield);
    wfiltd=filter(bbf,aaf,wfiltd);
    uzkd=filter(bbf,aaf,uzkd);
    
    md=filter(bbf,aaf,md);
    
    isSd=(T*[iad ibd icd]')';                % A, Statorstromraumzeiger, gefiltert
    isd=sqrt(isSd(:,1).^2+isSd(:,2).^2);     % A, Betrag des Statorstromraumzeigers
    phiid=atan2(isSd(:,2),isSd(:,1));        % rad, Winkel des Statorstromraumzeigers
    
    %% Bestimmung des Sollwinkels des Stromraumzeigers
    ismax=max(is);
    indi=min(find(is>ismax*0.9));            % 1, Index des ersten Punktes bei dem der Betrag des Stromraumzeigers 90% seines Maximums erreicht hat
    phisoll=mod(phii(indi)*180/pi,360);      % deg, Winkel des Stromraumzeigers an dieser Stelle
    phisoll=round(phisoll/10)*10;            % deg, Rundung auf 10° um auf die in der Variablen "phis" angegebenen Werte zu kommen
    
    % Zuordnung der Messwerte auf, über die Versuche hinweg, einheitliche Variable
    % als "ip" wird jener Strangstrom bezeichnet der zuerst den positiven Ast durchläuft
    %     "up" ist die dazugehörige Strangspannung bzw. Strangsollspannung
    % als "in" wird jener Strangstrom bezeichnet der zuerst den negativen Ast durchläuft
    %     "un" ist die dazugehörige Strangspannung bzw. Strangsollspannung
    % als "i0" wird der Strom bezeichnet, der auf dem Wert 0 bleiben sollte
    %     "un0" ist die Spannung am stromlosen Strang (N5000-Messung)
    %     der Namenszusatz "d" weist, wie auch weiter oben, auf vom dSpace
    %     System gemessen Größen hin
    %      "u0d" ist die Sollspannung der stromlosen Halbbrücke
    %  "fnpos", "fnneg" sind figure numbers für die Darstellung
    %  "spos", "sneg" sind Strings für die Betitelung der Darstellungen
    switch phisoll
        case 90
            % N5000
            up=uabc(:,2);
            un=uabc(:,3);
            un0=uabc(:,1);
            
            ip=iabc(:,2);
            in=iabc(:,3);
            i0=iabc(:,1);
            % dSpace
            upd=ubd;
            und=ucd;
            u0d=uad;
            
            ipd=ibd;
            ind=icd;
            i0d=iad;
            
            
            fnpos=200;
            fnneg=300;
            spos='b';
            sneg='c';
            
        case 210
            % N5000
            up=uabc(:,3);
            un=uabc(:,1);
            un0=uabc(:,2);
            
            ip=iabc(:,3);
            in=iabc(:,1);
            i0=iabc(:,2);
            % dSpace
            upd=ucd;
            und=uad;
            u0d=ubd;
            
            ipd=icd;
            ind=iad;
            i0d=ibd;
            
            fnpos=300;
            fnneg=100;
            spos='c';
            sneg='a';
            
        case 330
            % N5000
            up=uabc(:,1);
            un=uabc(:,2);
            un0=uabc(:,3);
            
            ip=iabc(:,1);
            in=iabc(:,2);
            i0=iabc(:,3);
            % dSpace
            upd=uad;
            und=ubd;
            u0d=ucd;
            
            ipd=iad;
            ind=ibd;
            i0d=icd;
            
            fnpos=100;
            fnneg=200;
            spos='a';
            sneg='b';
            
            
        otherwise
            error(['phisoll = ' num2str(phisoll) ' ist unbekannt']);
    end;  % switch phisoll
    
    
    %% Ausgleichsgeraden N5000, positiver Strom
    % Für die zeitliche Synchronisation werden die beiden markanten Punkte
    % positiver Scheitelwert von ip und negativer Scheitelwert von ip verwendet
    % (ip...der Strangstrom der zuerst den positiven Ast durchläuft)
    % Dazu werden vier Ausgleichsgeraden berechnet
    %  g1:   0.1*ismax <= ip <= 0.9*ismax  ansteigender Ast der Kurve
    %  g2:   0.1*ismax <= ip <= 0.9*ismax  abfallender Ast der Kurve
    %  g3:   -0.9*ismax <= ip <= -0.1*ismax  abfallender Ast der Kurve
    %  g4:   -0.9*ismax <= ip <= -0.1*ismax  ansteigender Ast der Kurve
    % positver Scheitel: S1=(tp1/ip1)    Schnittpunkt g1 und g2
    % negativer Scheitel: S2=(tp2/ip2)   Schnittpunkt g3 und g4
    %
    
    % Filterkoeffizienten, gleitender Mittelwert zur Bereichsbestimmung, N5000
    nn_bereich=round(Tfbereich/Tn);
    bb_b=ones(nn_bereich,1);
    aa_b=zeros(nn_bereich,1);
    aa_b(1)=nn_bereich;
    
    isf=filtfilt(bb_b,aa_b,is);
    
    index=find((isf>0.1*ismax)&(isf<0.9*ismax));
    aux=find(diff(index)>10);
    % g1
    ai1=index(1);
    ei1=index(aux(1));
    g1=polyfit(t(ai1:ei1),ip(ai1:ei1),1);
    
    % g2
    ai2=index(aux(1)+1);
    ei2=index(aux(2));
    g2=polyfit(t(ai2:ei2),ip(ai2:ei2),1);
    
    % g3
    ai3=index(aux(2)+1);
    ei3=index(aux(3));
    g3=polyfit(t(ai3:ei3),ip(ai3:ei3),1);
    
    % g4
    ai4=index(aux(3)+1);
    ei4=index(end);
    g4=polyfit(t(ai4:ei4),ip(ai4:ei4),1);
    
    % S1
    t1=(g2(2)-g1(2))/(g1(1)-g2(1));
    ip1=polyval(g1,t1);
    
    % S2
    t2=(g4(2)-g3(2))/(g3(1)-g4(1));
    ip2=polyval(g3,t2);
    
    %% Ausgleichsgeraden dSpace, positiver Strom
    % Filterkoeffizienten gleitender Mittelwert zur Bereichsbestimmung, dSpace
    % Das stimmt jetzt nicht mit der Filterung von N500 überein,
    % macht aber nichts, da es hier nur um die Bereichsbestimmung geht
    nn_bereichd=round(Tfbereich/Td);
    bb_bd=ones(nn_bereichd,1);
    aa_bd=zeros(nn_bereichd,1);
    aa_bd(1)=nn_bereichd;
    
    isdf=filtfilt(bb_bd,aa_bd,isd);
    
    
    ismaxd=max(isd);
    
    index=find((isdf>0.1*ismaxd)&(isdf<0.9*ismaxd));
    aux=find(diff(index)>10);
    % g1
    ai1d=index(1);
    ei1d=index(aux(1));
    g1d=polyfit(td(ai1d:ei1d),ipd(ai1d:ei1d),1);
    
    % g2
    ai2d=index(aux(1)+1);
    ei2d=index(aux(2));
    g2d=polyfit(td(ai2d:ei2d),ipd(ai2d:ei2d),1);
    
    % g3
    ai3d=index(aux(2)+1);
    ei3d=index(aux(3));
    g3d=polyfit(td(ai3d:ei3d),ipd(ai3d:ei3d),1);
    
    % g4
    ai4d=index(aux(3)+1);
    ei4d=index(end);
    g4d=polyfit(td(ai4d:ei4d),ipd(ai4d:ei4d),1);
    
    % S1
    t1d=(g2d(2)-g1d(2))/(g1d(1)-g2d(1));
    ip1d=polyval(g1d,t1d);
    
    % S2
    t2d=(g4d(2)-g3d(2))/(g3d(1)-g4d(1));
    ip2d=polyval(g3d,t2d);
    
    %% Kontrolle
    figure(10);
    plot(t,ip,t(ai1:ei1),ip(ai1:ei1),'-r',t(ai2:ei2),ip(ai2:ei2),'-c',t(ai3:ei3),ip(ai3:ei3),'-m',t(ai4:ei4),ip(ai4:ei4),'-g');
    hold on;
    plot(t1,ip1,'r*',t2,ip2,'b*');
    grid on;
    hold off;
    title('Kontrolle der Schnittpunkte, N5000-Messung');
    xlabel('Zeit in s');
    ylabel('Positiver Strom in A');
    legend('gesamt','Punkte von g1','Punkte von g2','Punkte von g3','Punkte von g4','S1','S2','Location','NorthEast');
    
    figure(11);
    plot(td,ipd,td(ai1d:ei1d),ipd(ai1d:ei1d),'-r',td(ai2d:ei2d),ipd(ai2d:ei2d),td(ai3d:ei3d),ipd(ai3d:ei3d),'-r',td(ai4d:ei4d),ipd(ai4d:ei4d),'-r');
    hold on;
    plot(t1d,ip1d,'r*',t2d,ip2d,'b*');
    grid on;
    hold off;
    title('Kontrolle der Schnittpunkte, dSpace-Messung');
    xlabel('Zeit in s');
    ylabel('Positiver Strom gefiltert in A');
    legend('gesamt','Punkte von g1','Punkte von g2','Punkte von g3','Punkte von g4','S1','S2','Location','NorthEast');
    
    %% Anpassung der Zeitbasis
    % Die Zeit zwischen den beiden Punkten S1 und S2 wird gleichgesetzt
    % die N5000 Zeit wird auf dSpace Zeit umgerechnet   ( td=tn*ktn )
    % (td1-td2) = ktn*(t2-t1)
    ktn=(t2d-t1d)/(t2-t1)
    tn=t*ktn;
    
    %% Zeitliche Verschiebung
    % Nach der Anpassung der Zeit können die Verläufe aneinander ausgerichtet
    % werden. Die Punkte S1 und S1d werden übereinander gelegt
    t0n=t1d-t1*ktn;
    
    %% Verstärkungsfehler
    % Die Spanne ip1-ip2 (N5000) wird an die Spanne ip1d-ip2d angepasst
    % (ip1d-ip2d)=kin*(ip1-ip2)
    kin=(ip1d-ip2d)/(ip1-ip2)
    ipn=ip*kin;
    
    %% Offsetkorrektur
    % Aus beiden Verläufen, ip und ipd, wird ein eventuell vorhandener Offset entfernt
    % Die Scheitelwerte sollten betragsgleich sein
    ipoffset=(ip1+ip2)/2;
    ipoffsetd=(ip1d+ip2d)/2;
    
    % Kontrollplot
    figure(12);
    plot(td,ipd-ipoffsetd,'b',tn+t0n,(ip-ipoffset)*kin,'-r');
    grid on;
    xlabel('Zeit in s');
    ylabel('Positive Ströme aneinander ausgerichtet');
    legend('dSpace gefiltert','N5000','Location','NorthEast');
    
    
    % zusätzliche Filterung mit gleitendem Mittelwert (akausal) für die Darstellung
    
    nnkn=round(Tfdarst/Tn);        % 1, Filterbreite in Abtastwerten für N5000-Messung
    nnkd=round(Tfdarst/Td);        % 1, Filterbreite in Abtastwerten für dSpace-Messung, Anpassung an die unterschiedliche Abtastrate
    bbkn=ones(nnkn,1);             % Filterkoeffizienten N5000-Messung
    aakn=zeros(nnkn,1);
    aakn(1)=nnkn;
    
    bbkd=ones(nnkd,1);             % Filterkoeffizienten dSpace-Messung
    aakd=zeros(nnkd,1);
    aakd(1)=nnkd;
    
    figure(13);
    plot(td,filtfilt(bbkd,aakd,ipd-ipoffsetd),'b',tn+t0n,filtfilt(bbkn,aakn,(ip-ipoffset)*kin),'-r');
    grid on;
    xlabel('Zeit in s');
    ylabel('Positive Ströme aneinander ausgerichtet');
    legend('dSpace akausal gefiltert','N5000 akausal gefiltert','Location','NorthEast');
    
    figure(14);
    plot(td,filtfilt(bbkd,aakd,ipd-ipoffsetd)-interp1(tn+t0n,filtfilt(bbkn,aakn,(ip-ipoffset)*kin),td,'linear','extrap'),'-r');
    grid on;
    xlabel('Zeit in s');
    ylabel('Differenz der positiven Ströme');
    title('Positiver Strom aus N5000-Messung linear über dSpace Zeit interpoliert');
    
    %% Uzk Korrektur
    
    
    aux=min(find(diff(ip)>0.2));
    %aux=min(find(t>t(aux)-1));
    aux=min(find(t>t(aux)-2));
    ai=min(find(t>t(aux)-4));
    Uzk=2*mean(u0(ai:aux))          % V, Zwischenkreisspannung, solange isoll=0 gilt sollten alle drei Halbbrücken Tastverhältnis 0.5 ausgeben
                                   %     also halbe Zwischenkreisspannung
    aux=find(td<0.2); % 0.5 org    % 1, Index des Bereiches der Aufzeichung im Pretrigger. dSpace triggert mit Start der Sollstromrampe, dort gilt td=0. 
    
    kzk=Uzk/mean(uzkfiltd(aux));   % 1, Verstärkungsfehler der dSpace Messung für die Zwischenkreisspannung (könnte aber auch an einem Offset liegen) 
    
    
    
    
    %% Interpolation
    ipnid=interp1(tn+t0n,ipn,td,'linear','extrap'); % A, über der dSpace Zeit interpolierter N5000- Strom 
    u0nid=interp1(tn+t0n,u0,td,'linear','extrap'); % V, über der dSpace Zeit interpolierte  N5000- Sternpunktsspannung
    
    uposd=upd*kzk-u0nid+uzkfiltd*kzk/2;     % V, dSpace-Sollspannung wird mit uzkfiltd auf Tastverhältnis umgerechnet
                                   %     d=upd/uzkfiltd+0.5   Der Umrichter macht mit der tatsächlichen Zwischenkreisspannung Uzk
                                   %     daraus die Spannung u=d*Uzk=upd*Uzk/uzkfiltd+0.5*Uzk=upd*kzk+Uzk/2 
                                   %     und davon wird nun die über der dSpace Zeit interpolierte Sternpunktsspannung "u0nid" abgezogen
                                   %     
                                   %     Für den Regler erscheint eigentlich die Spannung u/kzk 
                                   %     uposd/kzk=upd+uzkfiltd/2-u0nid/kzk
                                   
    unegd=und*kzk-u0nid+uzkfiltd*kzk/2;     % V, dasselbe für die Halbbrücke die zuerst den negativen Strom führt
    
    
    switch spos
        case 'a'
            gpindex=1;
        case 'b'
            gpindex=2;
        case 'c'
            gpindex=3;
        otherwise
            gpindex=0;
    end;        
    
    switch sneg
        case 'a'
            gnindex=1;
        case 'b'
            gnindex=2;
        case 'c'
            gnindex=3;
        otherwise
            gnindex=0;
    end;        
    
    aux=find(abs(ipd)>5);
    gpd(gpindex,:)=polyfit(abs(ipd(aux)),abs(uposd(aux)),1);
    aux=find(abs(ind)>5);
    gnd(gnindex,:)=polyfit(abs(ind(aux)),abs(unegd(aux)),1);
    
    aux=find(abs(ip)>1);
    gpn(gpindex,:)=polyfit(abs(ip(aux)),abs(up(aux)),1);
    aux=find(abs(in)>1);
    gnn(gnindex,:)=polyfit(abs(in(aux)),abs(un(aux)),1);
    
    
    
    %% Darstellung
    % Filter
    nn=round(Tfkenn/Td);
    bb=ones(nn,1);
    aa=zeros(nn,1);
    aa(1)=nn;
    
    uposdf=filtfilt(bb,aa,uposd);
    ipdf=filtfilt(bb,aa,ipd);
    
    unegdf=filtfilt(bb,aa,unegd);
    indf=filtfilt(bb,aa,ind);
    
    
    figure(fnpos);                                  % die Halbbrücke die zuerst positiven Strom führt
    ch=get(fnpos,'children');
    if ~isempty(ch);
        hold on;
        plot(ipdf,uposdf,farben(wahl));
        hold off;
    else
        plot(ipdf,uposdf,farben(wahl));
        grid on;
        xlabel('Strom, gefiltert in A');
        ylabel('Spannungsabfall, gefiltert in V');
        title(['Strang ' spos]);
    end;
    
    figure(fnpos+1);                            % die Halbbrücke die zuerst positiven Strom führt, Absolutwerte
    ch=get(fnpos+1,'children');
    if ~isempty(ch);
        hold on;
        plot(abs(ipdf),abs(uposdf),farben(wahl));
        hold off;
    else
        plot(abs(ipdf),abs(uposdf),farben(wahl));
        grid on;
        xlabel('|Strom, gefiltert| in A');
        ylabel('|Spannungsabfall, gefiltert| in V');
        title(['Strang ' spos]);
    end;
    
    
    figure(fnneg);                              % die Halbbrücke die zuerst negativen Strom führt
    ch=get(fnneg,'children');
    if ~isempty(ch);
        hold on;
        plot(indf,unegdf,farben(wahl));
        hold off;
    else
        plot(indf,unegdf,farben(wahl));
        grid on;
        xlabel('Strom, gefiltert in A');
        ylabel('Spannungsabfall, gefiltert in V');
        title(['Strang ' sneg]);
    end;
    
    figure(fnneg+1);                           % die Halbbrücke die zuerst negativen Strom führt, Absolutwerte
    ch=get(fnneg+1,'children');
    if ~isempty(ch);
        hold on;
        plot(abs(indf),abs(unegdf),farben(wahl));
        hold off;
    else
        plot(abs(indf),abs(unegdf),farben(wahl));
        grid on;
        xlabel('|Strom, gefiltert| in A');
        ylabel('|Spannungsabfall, gefiltert| in V');
        title(['Strang ' sneg]);
    end;
    
    
    
    figure(500);                    % Alle gemeinsam
    ch=get(500,'children');
    if ~isempty(ch);
        hold on;
        plot(ipdf,uposdf,farben(wahl));
        plot(indf,unegdf,['--' farben(wahl)]);
        hold off;
    else
        plot(ipdf,uposdf,farben(wahl));
        grid on;
        xlabel('Strom, gefiltert in A');
        ylabel('Spannungsabfall, gefiltert in V');
        title(['Alle']);
        hold on;
        plot(indf,unegdf,['--' farben(wahl)]);
        hold off;
    end;
    
end;













        