function [tcc1,tcc2] = tcc_method4(p00)

addpath /home/sergio/MATLABCODE/LOADMIE

if ~isfield(p00,'sarta_lvlDMEice')
  disp('setting DMEice = 60 um')
  p00.sarta_lvlDMEice = ones(size(p00.ciwc)) * 60;
end
if ~isfield(p00,'sarta_lvlDMEwater')
  disp('setting DMEwater = 20 um')
  p00.sarta_lvlDMEwater = ones(size(p00.clwc)) * 20;
end

if isfield(p00,'sarta_lvlODice') & isfield(p00,'sarta_lvlODwater') 
  p0 = p00;
else
  disp('need to quickly run driver_sarta_cloud_rtp')

  addpath /home/sergio/MATLABCODE/matlib/clouds/sarta
  run_sarta.clear = -1;
  run_sarta.cloud = -1;
  run_sarta.cumsum = 9999;
  run_sarta.cumsum = -1;

  [hsarta,ha,psarta,pa] = driver_sarta_cloud_rtp(h,[],p,[],run_sarta);
  cder = ['!cd ' homedir];
  eval(cder);
  p0 = psarta;
end

p0 = p00;

[numlevs,numprof] = size(p0.cc);

%%% ECNMWF documentation recommended by Reima Erasmaa 9211-part-iv-physical-processes.pdf
%%% ECMWWF documentation recommended by Alan Geer     18714-part-iv-physical-processes.pdf

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%   using rough factors %%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

gg_to_od = 1e5;

clear *fac*

%% (B) this DOES include exponential factor for cloud overlap, eqn 2.19
%% which depends on effective asymmetry, SSA and optical depth
%% so it depends on cloud amount

mu = 1.0; %% assume for nadir, I cannot imagine ECMWF fields depend on "view angle"

for pp = 1 : length(p0.stemp)
  cc = p0.cc(:,pp);
  cc = p0.cc(2:numlevs,pp);
  ciwc = p0.ciwc(2:numlevs,pp);
  clwc = p0.clwc(2:numlevs,pp);
  
  ciwc_od = p0.sarta_lvlODice(2:numlevs,pp);
  clwc_od = p0.sarta_lvlODwater(2:numlevs,pp);
  fac = ciwc_od + clwc_od;

  fac = (1-0.5*1*1)*fac;                   %% pretend SSA ~ 0.5, g ~ 1
  expfac = 1 - exp(-fac);

  oneminus = 1-cc.*expfac;
  gah = cumprod(oneminus);
  tcc1(pp) = 1 - gah(end);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if ~exist('Ei')
  [nlevs,nprofs] = size(p0.sarta_lvlDMEice);

  %% not so fast
  %{
  all = (1:nprofs*nlevs);

  [Ejunk,Wjunk,Gjunk] = loadmie_tau_EWG(960,p0.sarta_lvlDMEice(:),'I',4,-1,-1,ones(1,nprofs*nlevs),1);
  yes = find(isfinite(p0.sarta_lvlODice(:)) & isfinite(p0.sarta_lvlDMEice(:)) & ...
             (p0.sarta_lvlODice(:) > eps) & (p0.sarta_lvlDMEice(:) > eps));
  no = setdiff(all,yes');
  Ejunk(no) = 0; Wjunk(no) = 0; Gjunk(no) = 0;
  Ei = reshape(Ejunk,nlevs,nprofs);
  Wi = reshape(Wjunk,nlevs,nprofs);
  Gi = reshape(Gjunk,nlevs,nprofs);

  [Ejunk,Wjunk,Gjunk] = loadmie_tau_EWG(960,p0.sarta_lvlDMEwater(:),'W',250,1,6,ones(1,nprofs*nlevs),1);
  yes = find(isfinite(p0.sarta_lvlODwater(:)) & isfinite(p0.sarta_lvlDMEwater(:)) & ...
             (p0.sarta_lvlODwater(:) > eps) & (p0.sarta_lvlDMEwater(:) > eps));
  no = setdiff(all,yes');
  Ejunk(no) = 0; Wjunk(no) = 0; Gjunk(no) = 0;
  Ew = reshape(Ejunk,nlevs,nprofs);
  Ww = reshape(Wjunk,nlevs,nprofs);
  Gw = reshape(Gjunk,nlevs,nprofs);
  %}

  %% faster
  all = (1:nprofs*nlevs);

  junk = p0.sarta_lvlDMEice(:);
  yes = find(isfinite(p0.sarta_lvlODice(:)) & isfinite(p0.sarta_lvlDMEice(:)) & ...
             (p0.sarta_lvlODice(:) > 1e-6) & (p0.sarta_lvlDMEice(:) > 1e-3));
  [Exjunk,Wxjunk,Gxjunk] = loadmie_tau_EWG(960,junk(yes),'I',4,-1,-1,ones(1,length(yes)),1);
  Ejunk = zeros(size(junk)); Ejunk(yes) = Exjunk;
  Wjunk = zeros(size(junk)); Wjunk(yes) = Wxjunk;
  Gjunk = zeros(size(junk)); Gjunk(yes) = Gxjunk;
  Ei = reshape(Ejunk,nlevs,nprofs);
  Wi = reshape(Wjunk,nlevs,nprofs);
  Gi = reshape(Gjunk,nlevs,nprofs);

  junk = p0.sarta_lvlDMEwater(:);
  yes = find(isfinite(p0.sarta_lvlODwater(:)) & isfinite(p0.sarta_lvlDMEwater(:)) & ...
             (p0.sarta_lvlODwater(:) > 1e-6) & (p0.sarta_lvlDMEwater(:) > 1e-3));
  [Exjunk,Wxjunk,Gxjunk] = loadmie_tau_EWG(960,junk(yes),'W',250,1,6,ones(1,length(yes)),1);
  Ejunk = zeros(size(junk)); Ejunk(yes) = Exjunk;
  Wjunk = zeros(size(junk)); Wjunk(yes) = Wxjunk;
  Gjunk = zeros(size(junk)); Gjunk(yes) = Gxjunk;
  Ew = reshape(Ejunk,nlevs,nprofs);
  Ww = reshape(Wjunk,nlevs,nprofs);
  Gw = reshape(Gjunk,nlevs,nprofs);

end

for pp = 1 : length(p0.stemp)
  cc = p0.cc(:,pp);
  cc = p0.cc(2:numlevs,pp);
  ciwc = p0.ciwc(2:numlevs,pp);
  clwc = p0.clwc(2:numlevs,pp);

  %% more involved try, to use better ice SSA and sym (and ditto for water)
  %% we actually need atmospheric OD, but forget this for now
  od_level_i  = p0.sarta_lvlODice(2:numlevs,pp) + p0.sarta_lvlODwater(2:numlevs,pp); %% total OD
  ssa_level_i = (Wi(pp) + Ww(pp))/2;
  asym_level_i = Gi(pp)*mean(p0.sarta_lvlODice(2:numlevs,pp)) + Gw(pp)*mean(p0.sarta_lvlODwater(2:numlevs,pp));
  asym_level_i = asym_level_i / (mean(p0.sarta_lvlODice(2:numlevs,pp)) + mean(p0.sarta_lvlODwater(2:numlevs,pp)));
  fac    = (1-ssa_level_i.*asym_level_i.*asym_level_i).*od_level_i;
  expfac = 1 - exp(-fac);

  oneminus = 1-cc.*expfac;
  gah = cumprod(oneminus);
  tcc2(pp) = 1 - gah(end);
end

tcc1(tcc1 > 1) = 1; tcc1(tcc1 < 0) = 0;
tcc2(tcc2 > 1) = 1; tcc2(tcc2 < 0) = 0;
