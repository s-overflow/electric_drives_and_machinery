function [sys,x0,str,ts] = varhit2tv(t,x,u,flag,Ts,tv)
%VSFUNC Variable step S-function example.
%   This example S-function illustrates how to create a variable step
%   block in Simulink.  This block implements a variable step delay
%   in which the first input is delayed by an amount of time determined
%   by the second input:
%
%     dt      = u(2)
%     y(t+dt) = u(t)
%
%   See also SFUNTMPL, CSFUNC, DSFUNC.

%   Copyright 1990-2002 The MathWorks, Inc.
%   $Revision: 1.10 $

%
% The following outlines the general structure of an S-function.
%

zeig=0;

switch flag

  %%%%%%%%%%%%%%%%%%
  % Initialization %
  %%%%%%%%%%%%%%%%%%
  case 0
    [sys,x0,str,ts]=mdlInitializeSizes;

  %%%%%%%%%%
  % Update %
  %%%%%%%%%%
  case 2
    sys=mdlUpdate(t,x,u,Ts,tv,zeig);

  %%%%%%%%%%%
  % Outputs %
  %%%%%%%%%%%
  case 3
    sys=mdlOutputs(t,x,u,Ts,zeig);

  %%%%%%%%%%%%%%%%%%%%%%%
  % GetTimeOfNextVarHit %
  %%%%%%%%%%%%%%%%%%%%%%%
  case 4
    sys=mdlGetTimeOfNextVarHit(t,x,u,Ts,tv,zeig);

  %%%%%%%%%%%%%
  % Terminate %
  %%%%%%%%%%%%%
  case 9
    sys=mdlTerminate(t,x,u);
  
  %%%%%%%%%%%%%%%%%%%
  % Unhandled flags %
  %%%%%%%%%%%%%%%%%%%
  case 1
    sys = [];

  %%%%%%%%%%%%%%%%%%%%
  % Unexpected flags %
  %%%%%%%%%%%%%%%%%%%%
  otherwise
    error(['Unhandled flag = ',num2str(flag)]);

end

end % sfuntmpl

%
%=============================================================================
% mdlInitializeSizes
% Return the sizes, initial conditions, and sample times for the S-function.
%=============================================================================
%
function [sys,x0,str,ts]=mdlInitializeSizes

%
% call simsizes for a sizes structure, fill it in and convert it to a
% sizes array
%
sizes = simsizes;

sizes.NumContStates  = 0;
sizes.NumDiscStates  = 2;
sizes.NumOutputs     = 2;
sizes.NumInputs      = 2;
sizes.DirFeedthrough = 1;
sizes.NumSampleTimes = 1;     % at least one sample time is needed

sys = simsizes(sizes);

%
% initialize the initial conditions
%
x0  = [1 0];

%
% str is always an empty matrix
%
str = [];

%
% initialize the array of sample times
%
ts  = [-2 0];      % variable sample time

end % mdlInitializeSizes

%
%=============================================================================
% mdlUpdate
% Handle discrete state updates, sample time hits, and major time step
% requirements.
%=============================================================================
%
function sys=mdlUpdate(t,x,u,Ts,tv,zeig)
tu=Ts-u(2);
switch x(1)
    case 1   % A  am Beginn
        sys=[2 u(1)];
    case 2   % B  Su wird ausgeschaltet
        sys=[3 x(2)];
    case 3   % C So wird eingeschaltet
        sys=[4 x(2)];
    case 4   % D So wird ausgeschaltet
        if tu<=2*tv
            sys=[1 x(2)+1];
        else    
            sys=[5 x(2)];
        end;    
        % falls tu/2 <= tv
        % dann wechsle auf A, sonst auf E
    case 5   % E Su wird eingeschaltet    
        sys=[1 x(2)+1];
    otherwise
        error('mdlUpdate: unbekannter Zustand')
end      
% if x~=u(1)
%     sys=u(1);
% else
%     sys=x;
% end;    

% if zeig==1
% disp('Update')
% disp([t x sys])
% end;
end % mdlUpdate

%
%=============================================================================
% mdlOutputs
% Return the block outputs.
%=============================================================================
%
function sys=mdlOutputs(t,x,u,Ts,zeig)
    %x
switch x(1)
    case 1   % A  am Beginn
        sys=[0 1];
    case 2   % B  Su wird ausgeschaltet
        sys=[0 0];
    case 3   % C So wird eingeschaltet
        sys=[1 0];
    case 4   % D So wird ausgeschaltet
        sys=[0 0];
    case 5   % E Su wird eingeschaltet    
        sys=[0 1];
    otherwise
        error('mdlOutputs: unbekannter Zustand')
end      
% if x~=u(1)
%     if u(2)==Ta
%         sys=1;
%     else
%         sys=0;
%     end;
% else
%     if t<(u(1)*Ta+Ta/2)
%         sys=1;
%     else
%         sys=0;
%     end;
% end;    

% if zeig==1
% disp('Output')
% t %disp(t)
% x %disp(x)
% end;


end % mdlOutputs

%
%=============================================================================
% mdlGetTimeOfNextVarHit
% Return the time of the next hit for this block.  Note that the result is
% absolute time.
%=============================================================================
%
function sys=mdlGetTimeOfNextVarHit(t,x,u,Ts,tv,zeig)
tu=Ts-u(2);
%x
switch x(1)
    case 1   % A  am Beginn
        sys=x(2)*Ts+tu/2;
    case 2   % B  Su wird ausgeschaltet
        sys=x(2)*Ts+tu/2+tv;
    case 3   % C So wird eingeschaltet
        sys=(x(2)+1)*Ts-tu/2;
    case 4   % D So wird ausgeschaltet
        if tu<=2*tv
            sys=(x(2)+1)*Ts;
        else    
            sys=(x(2)+1)*Ts-tu/2+tv;
        end;    
        % falls tu/2 <= tv
        % dann wechsle auf A, sonst auf E
    case 5   % E Su wird eingeschaltet    
        sys=(x(2)+1)*Ts;
    otherwise
        error('mdlGetTimeOfNextVarHit: unbekannter Zustand')
end      
% if x~=u(1)
%     if (0<u(2))&(u(2)<Ta)
%         sys=u(1)*Ta+(Ta-u(2))/2;
%     else
%         sys=(u(1)+1)*Ta;
%     end;
% else
%     if t<(u(1)*Ta+Ta/2);
%         sys=u(1)*Ta+(Ta+u(2))/2;
%     else
%         sys=(u(1)+1)*Ta;
%     end;
% end;    

% if zeig==1
% disp('NextHit');
% disp([t,sys,u(:)']);
% u
% end

end % mdlGetTimeOfNextVarHit

%
%=============================================================================
% mdlTerminate
% Perform any end of simulation tasks.
%=============================================================================
%
function sys=mdlTerminate(t,x,u)

sys = [];

end % mdlTerminate
