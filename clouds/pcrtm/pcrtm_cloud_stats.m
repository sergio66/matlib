%disp('doing the PCRTM cloud stats ....')

clear totalODwater meanDMEwater maxCTOPwater da_w
clear totalODice meanDMEice maxCTOPice da_i

iAA = 2;  %% before Jan 2013
iAA = 1;  %% after  Jan 2013

for icol = iAA:ucol_num(ibox)
  clear da_w da_i

  da_w = find(cldphase(icol,:) == 1);   %% water cloud  WRONG BEFORE OCT 2012
  da_w = find(cldphase(icol,:) == 2);   %% water cloud  FIXED OCT 2012
  if length(da_w) > 1
    totalODwater(icol) = sum(cldopt(icol,da_w));   %% only uses lower clouds
    totalODwaterX(icol) = sum(sergio_water_opt);   %% new 03/29/2013, uses ALL
    meanDMEwater(icol) = mean(cldde(icol,da_w));
    maxCTOPwater(icol) = min(cldpres(icol,da_w));
  elseif length(da_w) == 1
    totalODwater(icol) = (cldopt(icol,da_w));     %% only uses lower clouds
    totalODwaterX(icol) = sum(sergio_water_opt);  %% new 03/29/2013, uses ALL
    meanDMEwater(icol) = (cldde(icol,da_w));
    maxCTOPwater(icol) = (cldpres(icol,da_w));
  else
    totalODwaterX(icol) = NaN;
    totalODwater(icol) = NaN;
    meanDMEwater(icol) = NaN;
    maxCTOPwater(icol) = NaN;
  end

  da_i = find(cldphase(icol,:) == 2);           %% cirrus cloud  WRONG BEFORE OCT 2012
  da_i = find(cldphase(icol,:) == 1);           %% cirrus cloud FIXED OCT 2012
  if length(da_i) > 1
    totalODice(icol) = sum(cldopt(icol,da_i));  %% only uses higher clouds
    totalODiceX(icol) = sum(sergio_ice_opt);    %% new 03/29/2013, uses ALL
    meanDMEice(icol) = mean(cldde(icol,da_i));
    maxCTOPice(icol) = min(cldpres(icol,da_i));
  elseif length(da_i) == 1
    totalODice(icol) = (cldopt(icol,da_i));   %% only uses higher clouds
    totalODiceX(icol) = sum(sergio_ice_opt);  %% new 03/29/2013, uses ALL
    meanDMEice(icol) = (cldde(icol,da_i));
    maxCTOPice(icol) = (cldpres(icol,da_i));
  else
    totalODiceX(icol) = NaN;
    totalODice(icol) = NaN;
    meanDMEice(icol) = NaN;
    maxCTOPice(icol) = NaN;
  end
end

%tmpjunk
%whos total* meanDME* maxCTOP* sergio_ice_opt sergio_water_opt
%  [ibox ucol_num(ibox)]

%% assume no ice or water in any of the Ncol0 profiles????
tmpjunk.lvlODice(:,ibox)   = sergio_ice_opt;
tmpjunk.lvlODwater(:,ibox) = sergio_water_opt;
tmpjunk.lvlggice(:,ibox)   = sergio_ice_gg;
tmpjunk.lvlggwater(:,ibox) = sergio_water_gg;

tmpjunk.totalODiceX(ibox)   = NaN;
tmpjunk.totalODwaterX(ibox) = NaN;
tmpjunk.totalODice(ibox) = NaN;
tmpjunk.meanDMEice(ibox) = NaN;
tmpjunk.maxCTOPice(ibox) = NaN;
tmpjunk.totalODwater(ibox) = NaN;
tmpjunk.meanDMEwater(ibox) = NaN;
tmpjunk.maxCTOPwater(ibox) = NaN;

%% now check for ice or water
if ucol_num(ibox) > iAA-1
  ixy = iAA:ucol_num(ibox);

  isi = find(isfinite(meanDMEice(ixy)));
  if length(isi) > 0
    summ = sum(ucol_num_same(ibox,ixy(isi)));
    tmpjunk.totalODiceX(ibox) = nansum(totalODiceX(ixy(isi)).*ucol_num_same(ibox,ixy(isi)))/summ;
    tmpjunk.totalODice(ibox) = nansum(totalODice(ixy(isi)).*ucol_num_same(ibox,ixy(isi)))/summ;
    tmpjunk.meanDMEice(ibox) = nansum(meanDMEice(ixy(isi)).*ucol_num_same(ibox,ixy(isi)))/summ;
    tmpjunk.maxCTOPice(ibox) = nansum(maxCTOPice(ixy(isi)).*ucol_num_same(ibox,ixy(isi)))/summ;
  end

  isw = find(isfinite(meanDMEwater(ixy)));
  if length(isw) > 0
    summ = sum(ucol_num_same(ibox,ixy(isw)));
    tmpjunk.totalODwaterX(ibox) = nansum(totalODwaterX(ixy(isw)).*ucol_num_same(ibox,ixy(isw)))/summ;
    tmpjunk.totalODwater(ibox) = nansum(totalODwater(ixy(isw)).*ucol_num_same(ibox,ixy(isw)))/summ;
    tmpjunk.meanDMEwater(ibox) = nansum(meanDMEwater(ixy(isw)).*ucol_num_same(ibox,ixy(isw)))/summ;
    tmpjunk.maxCTOPwater(ibox) = nansum(maxCTOPwater(ixy(isw)).*ucol_num_same(ibox,ixy(isw)))/summ;
  end
end

clear iAA
