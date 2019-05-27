function [tcc1,tcc2] = tcc_method3(p0)

addpath /home/sergio/MATLABCODE/LOADMIE

[numlevs,numprof] = size(p0.cc);

%%% ECNMWF documentation recommended by Reima Erasmaa 9211-part-iv-physical-processes.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   using rough factors %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%gg_to_od = input('Enter rough conversion from g/g to OD (0 makes TCC too small, 1e5 ok, 1e60 makes TCC like above) : NOT USED!!!! : ');
gg_to_od = 1e5;

clear *fac*

%% (B) this DOES include exponential factor for cloud overlap, eqn 2.19
%% which depends on effective asymmetry, SSA and optical depth
%% so it depends on cloud amount
for pp = 1 : length(p0.stemp)
  cc = p0.cc(:,pp);
  cc = p0.cc(2:numlevs,pp);
  ciwc = p0.ciwc(2:numlevs,pp);
  clwc = p0.clwc(2:numlevs,pp);
  
  fac = gg_to_od*(ciwc + clwc);            %%% total OD -- 1000 is a fudge to go from g/g to OD
  fac = ciwc*5/15e-5 + clwc*200/0.5e-3;    %%% total OD -- 1000 is a fudge to go from g/g to OD  
  fac = (1-0.5*1*1)*fac;                   %% pretend SSA ~ 0.5, g ~ 1
  expfac = 1 - exp(-fac);

  oneminus = 1-cc.*expfac;
  gah = cumprod(oneminus);
  tcc1(pp) = 1 - gah(end);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%tcc2 = tcc1;
%disp('WARNING : need the level ODs so quitting before trying the full ECMWF algorithm')
%return
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath /home/sergio/MATLABCODE/matlib/clouds/sarta
airslevels  = load('/home/sergio/MATLABCODE/airslevels.dat');
airsheights = load('/home/sergio/MATLABCODE/airsheights.dat');
[p1] = ice_water_deff_od_all(p0,airslevels,airsheights);

%% (C) this DOES include exponential factor for cloud overlap, eqn 2.19
%% which depends on effective asymmetry, SSA and optical depth
%% so it depends on cloud amount, use more accurate ODs

fudge = 0.05;   %% modify eqn in ECMWF Tech report
fudge = 1;      %% eqn in ECMWF Tech report

R = 287.05;
qi = p1.ciwc ./ p1.ptemp  .* p1.plevs * 100/R *1e3;
qi = max(eps,qi);
qw = p1.clwc ./ p1.ptemp  .* p1.plevs * 100/R *1e3;
qw = max(eps,qw);
a = 26.1571 * abs(log10(10^(-12) + qi)).^(-0.5995);
b = 0.6402  + 0.1810 * (log10(10^(-12) + qi));
ice_deff_sun_rikus = a + b.*(p1.ptemp-273 + 190);;
woo = find(p1.ciwc < eps | imag(ice_deff_sun_rikus) > eps | real(ice_deff_sun_rikus) < eps); ice_deff_sun_rikus(woo) = NaN;

if ~exist('Ei')
  iceDME = 10 * ones(size(p1.sarta_lvlDMEice));
  yes = find(isfinite(p1.sarta_lvlDMEice) & p1.sarta_lvlDMEice > 0);
  no  = find(isnan(p1.sarta_lvlDMEice) | isinf(p1.sarta_lvlDMEice) |  p1.sarta_lvlDMEice < eps);
  iceDME(yes) = p1.sarta_lvlDMEice(yes);

  iceDME = 10 * ones(size(p1.sarta_lvlDMEice));
  sun_rikus_dme = nanmean(ice_deff_sun_rikus);
  yes = find(isfinite(sun_rikus_dme) & sun_rikus_dme > 0);
  no  = find(isnan(sun_rikus_dme) | isinf(sun_rikus_dme) |  sun_rikus_dme < eps);
  iceDME(yes) = sun_rikus_dme(yes);

  [Ei,Wi,Gi] = loadmie_tau_EWG(960,iceDME  ,'I',4,-1,-1,ones(size(p1.sarta_lvlDMEice)),1);
  Ei(no) = 0;
  Wi(no) = 0;
  Gi(no) = 0;
  ice_yes = ones(size(p1.sarta_lvlDMEice));
  ice_yes(no) = 0;
  
  waterOD = ones(size(p1.cc)) * 20;
  [Ew,Ww,Gw] = loadmie_tau_EWG(960,waterOD,'W',250,1,6,ones(size(p1.cc)),1);
  no  = find(isnan(p1.sarta_lvlODwater) | isinf(p1.sarta_lvlODwater) | p1.sarta_lvlODwater < eps);
  Ew(no) = 0;
  Ww(no) = 0;
  Gw(no) = 0;
  water_yes = ones(size(p1.cc));
  water_yes(no) = 0;
  
end

for pp = 1 : length(p0.stemp)
  cc = p0.cc(:,pp);
  cc = p0.cc(2:numlevs,pp);
  ciwc = p0.ciwc(2:numlevs,pp);
  clwc = p0.clwc(2:numlevs,pp);

  %% simple try, constant SSA and asymm
  odfac  = p1.sarta_lvlODice(2:numlevs,pp)*Ei(pp) + p1.sarta_lvlODwater(2:numlevs,pp)*Ew(pp); %% total OD
  fac    = (1-0.5*1*1)*odfac;  %% pretend SSA ~ 0.5, g ~ 1
  expfac = 1 - exp(-fac);

  %% more involved try, to use better ice SSA and sym (and ditto for water)
  %% we actually need atmospheric OD, but forget this for now
  od_level_i  = p1.sarta_lvlODice(2:numlevs,pp) + p1.sarta_lvlODwater(2:numlevs,pp); %% total OD
  od_level_i  = p1.sarta_lvlODice(2:numlevs,pp)*ice_yes(pp) + p1.sarta_lvlODwater(2:numlevs,pp)*water_yes(pp); %% total OD  
  ssa_level_i = (Wi(pp) + Ww(pp))/2;
  asym_level_i = Gi(pp)*mean(p1.sarta_lvlODice(2:numlevs,pp)) + Gw(pp)*mean(p1.sarta_lvlODwater(2:numlevs,pp));
  asym_level_i = asym_level_i / (mean(p1.sarta_lvlODice(2:numlevs,pp)) + mean(p1.sarta_lvlODwater(2:numlevs,pp)));
  fac    = (1-ssa_level_i.*asym_level_i.*asym_level_i).*od_level_i;
  expfac = 1 - exp(-fac);

  oneminus = 1-cc.*expfac;
  gah = cumprod(oneminus);
  tcc2(pp) = 1 - gah(end);
end

tcc1(tcc1 > 1) = 1; tcc1(tcc1 < 0) = 0;
tcc2(tcc2 > 1) = 1; tcc2(tcc2 < 0) = 0;
