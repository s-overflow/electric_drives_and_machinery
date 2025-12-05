% R. Seebacher K.Krischan 9.3.2005
%
% Aufruf:
%            mw=mwgeigl(vname,fname);
%
% vname....Verzeichnisname in dem die Messwertdateien zu finden sind
% fname....Dateiname ohne Extension und ohnen Nummernerweiterung
% 
% Erwartet werden die dateien:  Dateiname.hed
%                               Dateinamex.dat   x=1,2...n
%
% ! Alle Dateien die sich mit dateinamex.dat, x lückenlos von 1 bis n, im angegebenen Verzeichnis finden lassen werden verwendet !  
% ! FORM REAL 32 !
% 

function mw=mwgeigl(vname,fname);


namefix=[vname '\' fname];
% header holen
% Header  
% 1. Timer Reset geht ganz einfach
hed=load([namefix '.hed']);
%fid=fopen([fname '.hed'],'r');
%s=char(fread(fid,'char')); % erstes Zeichen # zweites Zeichen gibt Anzahl beschreibender Zeichen
%fclose(fid);
%kommas=findstr(s',',');
% zwischen den ersten beiden liegt die gesuchte Zahl
%mganz=str2num(s(kommas(1)+1:kommas(2)-1)');
mganz=hed(2); % Messgrößenanzahl

Ta=hed(7);

% Zugehörige dat-Dateien suchen 

zz=1;
namefix=[vname '\' fname];
name=[namefix num2str(zz) '.dat'];
istda=exist(name,'file');
mw=[];
while istda==2
    
    fid=fopen(name,'r');
    s=fread(fid,2,'char'); % erstes Zeichen # zweites Zeichen gibt Anzahl beschreibender Zeichen
    anz=fread(fid,str2num(char(s(2))),'char');
    anz=str2num(char(anz')); % soviele Datenbytes für REAL 32
    mwteil=fread(fid,anz,'single'); %float32';
    fclose(fid);
    
    mwteil=reshape(mwteil,mganz,length(mwteil)/mganz)';  % In Form bringen
    mw=[mw;mwteil];  % Zusammensetzen der Einzelteile
    zz=zz+1;
    name=[namefix num2str(zz) '.dat'];
    istda=exist(name,'file');  % gibt es noch einen Teil?
end;
[m,n]=size(mw);
t=[0:m-1]'*hed(7);

mw=[t mw];




