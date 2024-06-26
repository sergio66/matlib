function p1 = do_the_reset_cprtop_cloudOD(p0,p1,cumsumOD,run_sarta);

%% this is basically "reset_cprtop"
%% except we replace cprtop1,cprtop2 with :  
%%   icecldY   ---> sarta_lvl_iceOD_1    ---> wgtpeakI
%%   watercldY ---> sarta_lvl_waterOD_1  ---> wgtpeakW

if nargin == 3
  run_sarta.talk = -1; %% quiet
end

if abs(cumsumOD) <= 99
  if run_sarta.talk == 1
    disp('  --->> resetting cloud top according to CUMULATIVE CLOUD OD SUM')
  end
  pICE   = p1.sarta_lvl_iceOD_1; 
  pWATER = p1.sarta_lvl_waterOD_1;         %% March 29, 2013
elseif abs(cumsumOD) > 99
  if run_sarta.talk == 1
    fprintf(1,'  --->> resetting cloud top according to CLOUD PEAK WGT FCN, xcumsum = %5i \n',cumsumOD)
  end
  pICE   = p1.sarta_wgtpeakI;    
  pWATER = p1.sarta_wgtpeakW;              %% April 1, 2013
end

iVersion = 0;  %% this is the original, simplest version
iVersion = 1;  %% this is a    better version, but only deals with cumsumOD > 0 to 9998, and 9999
iVersion = 2;  %% this is even better version, deals with cumsumOD > 0 to 9998, and 9999, and -9999

if iVersion == 0
  if run_sarta.talk == 1
    disp('  do_the_reset_cprtop_cloudOD.m resetting cloudtops vers 0')
  end
  p1 = do_the_reset_cprtop_cloudOD_vers0(p0,p1,pICE,pWATER,run_sarta);
elseif iVersion == 1
  if run_sarta.talk == 1
    disp('  do_the_reset_cprtop_cloudOD.m resetting cloudtops vers 1')
  end
  p1 = do_the_reset_cprtop_cloudOD_vers1(p0,p1,pICE,pWATER,run_sarta);
elseif iVersion == 2
  if run_sarta.talk == 1
    disp('  do_the_reset_cprtop_cloudOD.m resetting cloudtops vers 2')
  end
  p1 = do_the_reset_cprtop_cloudOD_vers2(p1,pICE,pWATER,cumsumOD,run_sarta);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
