function p1 = reset_cprtop_cloudOD(p0,cumsumOD,airslevels,airslayers,airsheights,iNew_or_Orig_CXWC2OD,run_sarta);

%% basically same as reset_cprtop_cloudOD.m
%% first part is same as compute_cloudOD.m but then this routine does much more

%% computes cloud ODs based on formulas given by Xianglei and Xiuhong
%% see PCRTM_compute_for_AIRS_spectra.m
%% if abs(cumsumOD) < 99   then look for where cumulative cloudOD == cumsum
%%    abs(cumsumOD) = 9999 then look for peak of cloud wgt fcn, 
%%        if cumsumOD == +9999 do          STROW PICK (ice cloud can be between 0 < p < 1000 mb),
%%        if cumsumOD == -9999 do MODIFIED STROW PICK (ice cloud can be between 0 < p < 400 mb),
%%  
%% see cloud_mean_press.m
%%   aa.icecldX,aa.watercldX = mean(CIWC), mean(CLWC) pressure level
%%   aa.icecldY,aa.watercldY = pressure level where normalized CIWC/CLWC exceed xcumsum if 0 < xcumsum < 1
%%                             else set to 1200 mb

if nargin == 4
  iNew_or_Orig_CXWC2OD =  0;  %%% change to OD = blah * qBlah / cc * diffZ; OD(cc < 1e-3) = 0 WHAT PCRTM DOES
  iNew_or_Orig_CXWC2OD = +1;  %%% change to OD = blah * qBlah * cc * diffZ                    Mar 2017 SERGIO
  iNew_or_Orig_CXWC2OD = -1;  %%% stick  to OD = blah * qBlah / cc * diffZ                    Pre March 2017  DEFAULT
  run_sarta.talk       = -1;  %% quiet
elseif nargin == 5
  run_sarta.talk       = -1;  %% quiet
end

if run_sarta.talk == 1  
  disp('computing level ODs and wgt functions')
end

p1 = p0;
p1.orig_ctop  = p1.cprtop;
p1.orig_ctop2 = p1.cprtop2;

iDebug = -1;
if iDebug > 0
  keyboard
  oo = find(p0.cprtop > 0 & p0.icecldX > 0);
  plot(p0.icecldX(oo)-p0.cprtop(oo))
  plot(p0.icecldX(oo),p0.cprtop(oo),'.',p0.icecldX(oo),p0.icecldX(oo))  %% so typically icecldX > cprtop ==> icecldX is lower than cprtop
  plotclouds(p0,1,2)
end

if run_sarta.talk == 1  
  disp('    computing ice/water ODs at each level, each profile .... ')
end

iFastOrSlow = 0;   %% do both for debug
iFastOrSlow = -1;  %% slow old way
iFastOrSlow = +1;  %% fast new way
if iFastOrSlow >= 0
  %toc
  [p1Fast,iceODFast,waterODFast] = ice_water_deff_od_vectorized(p1,airslevels,airslayers,airsheights,iNew_or_Orig_CXWC2OD);
  %toc
  p1Fast                 = sarta_level_ice_water_OD_1_vectorized(iceODFast,waterODFast,cumsumOD,p1Fast);
  %toc
end
if iFastOrSlow <= 0
  clear p1Slow iceODSlow* waterODSlow*
  ii=1;
    [p1Slow,iceODSlowX,waterODSlowX,extrajunk] = ice_water_deff_od(p1,airslevels,airslayers,airsheights,ii,iNew_or_Orig_CXWC2OD);
    p1Slow = sarta_level_ice_water_OD_1(iceODSlowX,waterODSlowX,cumsumOD,p1Slow,ii); 
    iceODSlow(:,ii)   = iceODSlowX;
    waterODSlow(:,ii) = waterODSlowX;
  for ii = 2 : length(p1.stemp)
    [p1Slow,iceODSlowX,waterODSlowX,extrajunk] = ice_water_deff_od(p1Slow,airslevels,airslayers,airsheights,ii,iNew_or_Orig_CXWC2OD);
    p1Slow = sarta_level_ice_water_OD_1(iceODSlowX,waterODSlowX,cumsumOD,p1Slow,ii); 
           %% NOTE THE cumsumOD here -- have to be careful in calling routine
           %% it may be looking for 0 <= cumsumOD <= 9999/100 
           %%   in which case it is looking for that value of cumulative OD 
           %%   from TOA to GND
           %% it may be looking for abs(cumsumOD) = 9999      
           %%   in which case it is looking for cumulative OD from TOA to GND == 1
           %% sets p1.sarta_lvl_iceOD_1, p1.sarta_lvl_waterOD_1
    iceODSlow(:,ii)   = iceODSlowX;
    waterODSlow(:,ii) = waterODSlowX;
  end
  %toc
end

if iFastOrSlow == 1
  p1 = p1Fast;
elseif iFastOrSlow == -1
  p1 = p1Slow;
else
  clf
  disp('debugging reset_cprtop_cloudOD.m')
  plot(1:length(p0.stemp),sum(iceODFast,1)-sum(iceODSlow,1),1:length(p0.stemp),sum(waterODFast,1)-sum(waterODSlow,1)); title('\delta icOD,waterOD')
    [sum(sum(iceODFast,1)-sum(iceODSlow,1)) sum(sum(waterODFast,1)-sum(waterODSlow,1))]
    [sum(sum(p1Fast.sarta_lvlDMEice-p1Slow.sarta_lvlDMEice)) sum(sum(p1Fast.sarta_lvlDMEwater-p1Slow.sarta_lvlDMEwater))]
    [sum(sum(p1Fast.sarta_lvlODice-p1Slow.sarta_lvlODice)) sum(sum(p1Fast.sarta_lvlODwater-p1Slow.sarta_lvlODwater))]
    [sum(p1Fast.sarta_lvl_iceOD_1-p1Slow.sarta_lvl_iceOD_1) sum(p1Fast.sarta_lvl_waterOD_1-p1Slow.sarta_lvl_waterOD_1)]
  addpath /home/sergio/MATLABCODE
  keyboard_nowindow
end

if iDebug > 0
  p10 = p1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[wgtW,wgtpeakWindex,wgtpeakW_tempr,wgtpeakW,wgtI,wgtpeakIindex,wgtpeakI_tempr,wgtpeakI] = cld_wgt_fcn(p1); %% leave p1 alone, sets cloud weight functions

%% now set p1 fields
p1.sarta_wgtI     = wgtI;   %% nlevs X nprof array of ice   cloud weight functions, assuming no atmosphere
p1.sarta_wgtW     = wgtW;   %% nlevs X nprof array of water cloud weight functions, assuming no atmosphere

p1.sarta_index_wgtpeakW = wgtpeakWindex;  %% index where wgtI peaks
p1.sarta_index_wgtpeakI = wgtpeakIindex;  %% index where wgtW peaks

p1.sarta_wgtpeakW = wgtpeakW;  %% pressure level where wgtI peaks, depends on sarta_lvlODice
p1.sarta_wgtpeakI = wgtpeakI;  %% pressure level where wgtW peaks, depends on sarta_lvlODwater

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% now do the actual replacement of cprtop/cprbot with above info
p1 = do_the_reset_cprtop_cloudOD(p0,p1,cumsumOD);

if iDebug > 0
  oo = find(p1.cprtop > 0 & wgtpeakI > 0);
  plot(oo,p10.cprtop(oo)-wgtpeakI(oo),oo,p1.cprtop(oo)-wgtpeakI(oo))
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

iJunk = -1;
if iJunk > 0
  %% this shows that wgtpeakW < sarta_lvl_waterOD_1 ie higher up!!!!!
  plot(p1.sarta_wgtpeakW,p1.sarta_lvl_waterOD_1,'o',p1.sarta_wgtpeakI,p1.sarta_lvl_iceOD_1,'rx',wgtpeakI,wgtpeakI)
   axis([0 1000 0 1000])

  plot(wgtpeakI,p1.cprtop,'o',wgtpeakW,p1.cprtop2,'ro',wgtpeakI,wgtpeakI); axis([0 1000 0 1000])
  dn = -1000 : 10 : +1000; nn = hist(wgtpeakI-p1.cprtop,dn); plot(dn,nn)
  dn = -1000 : 10 : +1000; nn = hist(wgtpeakW-p1.cprtop2,dn); plot(dn,nn)

  %% do simple RT
  ii = p0.nlevs(1);
  radI(ii,:) = ttorad(1231*ones(size(p1.stemp)),p1.stemp);
  for ii = p0.nlevs(1)-1 : -1 : +1
    tau = exp(-p1.sarta_lvlODice(ii,:));
    radI(ii,:) = radI(ii+1,:) .* tau + ttorad(1231*ones(size(p1.stemp)),p1.ptemp(ii,:)) .* (1 - tau);
  end

  ii = p0.nlevs(1);
  radW(ii,:) = ttorad(1231*ones(size(p1.stemp)),p1.stemp);
  for ii = p0.nlevs(1)-1 : -1 : +1
    tau = exp(-p1.sarta_lvlODwater(ii,:));
    radW(ii,:) = radW(ii+1,:) .* tau + ttorad(1231*ones(size(p1.stemp)),p1.ptemp(ii,:)) .* (1 - tau);
  end

  junkprof = 1 - exp(-(1:double(p0.nlevs(1)))/double(p0.nlevs(1)));  %% exponential atmosphere
  ii = p0.nlevs(1);
  radJ(ii,:) = ttorad(1231*ones(size(p1.stemp)),p1.stemp);
  for ii = p0.nlevs(1)-1 : -1 : +1
    tau = exp(-junkprof(ii))*ones(size(p1.stemp));
    radJ(ii,:) = radJ(ii+1,:) .* tau + ttorad(1231*ones(size(p1.stemp)),p1.ptemp(ii,:)) .* (1 - tau);
  end

  lala = sum(p1.sarta_lvlODice);
  scatter(ttorad(1231,wgtpeakI_tempr),radI(1,:),30,lala,'filled'); colorbar
  lala = sum(p1.sarta_lvlODwater);
  scatter(ttorad(1231,wgtpeakW_tempr),radW(1,:),30,lala,'filled'); colorbar
end

