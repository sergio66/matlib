function matchedcalflag = mkmatchedcalflag(iYear,iDoy, stProf)
%
% MKMATCHEDCALFLAG
%
% Given a year and day of year, load AIRIBRAD calflag data and
% match to AIRXBCAL clear subset observations by matching granule
% number and scanline between loaded calflag matrix and passed in
% profile structure.
%

% load calflag mat file
aiPdaycalflag = loadcalflag(iYear, iDoy, 1);
aiCalflag = loadcalflag(iYear, iDoy, 0);

%** need to make new array which matches up stProf arrays to
%** calflag elements. This is done through granule number
%** (stProf.findex) and scan line number (stProf.atrack)

aiMatchedcalflag = zeros(length(stProf.robs1),2378);
for i=1:length(stProf.robs1)
    if stProf.findex(i) == 0
        aiMatchedcalflag(i,:) = aiPdaycalflag(240, stProf.atrack(i), :);
    else
        aiMatchedcalflag(i,:) = aiCalflag(stProf.findex(i), stProf.atrack(i), ...
                                      :);
    end
end

end