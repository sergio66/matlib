function [emis] = emis_danz(lat,lon,rtime,efreq);
% Usage: [emis] = emis_danz_rtp(lat,lon,rtime,efreq);
%
% Returns Dan Zhou's land emissivity climatology
% Dan provides a monthly climatology, here we do both
% temporal and spatial linear interpolation.
%
% REQUIRES:
%     /asl/packages/time
%
% danz interpolant is big, keep it around
persistent danz
if isempty(danz)
  % load /asl/data/iremis/danz/danz_interpolant.mat
  % load /asl/rta/iremis/danz/danz_interpolant.mat
  loader = ['load ' set_path_to_danz '/danz_interpolant.mat'];
  eval(loader)  
end

% SVD basis vectors and mean 
% load /asl/data/iremis/danz/u_vector_global
% load /asl/rta/iremis/danz/u_vector_global
loader = ['load ' set_path_to_danz '/u_vector_global.mat'];
eval(loader)

% Pre-allocate u coefficients, nobs can be very large
[~, nobs] = size(lat);
newc = zeros(10,nobs);

% Now figure out numerical months
mtime = tai2dtime(rtime);

mon = single(day(mtime,'dayofyear')/365);
lat = single(lat);
lon = single(lon);

% Find interpolated expansion coefficients (linear is default)
for i=1:10
    newc(i,:) = danz(i).emis(lon,lat,mon);
end

% Expand with basis vectors u
% First, find id's of IASI channels we will use; hard-code later?
% load /asl/data/iremis/danz/iasi_f
% load /asl/rta/iremis/danz/iasi_f
loader = ['load ' set_path_to_danz '/iasi_f.mat'];
eval(loader)

[ichan, ~] = seq_match(fiasi,efreq);
emis = u(ichan,:)*newc;

% Add in constant emissivity (from u_vector_global)
for i=1:nobs
   emis(:,i) = emis(:,i) + em(ichan);
end
