function [h12] = p2hFAST2(pin1,pin2,airslevels,airslayers,airsheights)
%this function takes pressure in mb, and converts to height in m

% load airsheights.dat
% load airslevels.dat

h = airsheights;
p = airslevels;
pavg = airslayers;

%%pavg = zeros(100,1);
%%for ii = 1:100
%%  pavg(ii) = (p(ii+1)-p(ii))/log(p(ii+1)/p(ii));
%%end
%pavgN = p(1:end-1)-p(2:end);
%pavgD = log(p(1:end-1)./p(2:end));
%pavg  = pavgN./pavgD;

%if length(h) ~= length(pavg)
%  fprintf(1,'length(height) length9(pavg) = %3i %3i \n',length(h),length(pavg))
%  error('in p2hFAST length(h) ~= length(pavg)')
%end  
%plot(h,pavg)

h12 = interp1qr(pavg,h,[pin1 pin2]);

%if ((isnan(h12)) | h12 > 7.05e4)
%  h12  =  8.09e4;
%end

bad = find(isinf(h12) | isnan(h12) | h12 > 8.09e4);
h12(bad) = 8.09e4;

