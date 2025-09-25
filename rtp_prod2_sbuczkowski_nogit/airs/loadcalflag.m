function calflag = loadcalflag(iYear, iDoy, bPrevious)
%
% LOADCALFLAG
%
% For a given year and day of year, load the AIRIBRAD derived
% calflag mat file. This introduces a 240 x 135 x 2378 array named
% 'calflag' into the workspace which contains calflag values for
% all obs during the given day. 
%
% If the boolean flag bPrevious is set, load the calflag file for
% the previous day to give access to it's data for granule 240.
%


MATBASEDIR = '/asl/data/airs/AIRIBRAD_subset';

if bPrevious
    % convert time to matlab datetime format
    sYearDoy = sprintf('%4d%03d', iYear, iDoy);
    dtDate = datetime(sYearDoy, 'InputFormat', 'yyyyDDD');

    % subtract one day and convert back to year and iDoy
    iYear = year(dtDate-1);
    iDoy = day(dtDate-1, 'dayofyear');
end

matfile = sprintf('%s/%4d/meta_%03d.mat', MATBASEDIR, iYear, iDoy);
fprintf(1, 'Accessing %s for calflag data\n', matfile);
load(matfile, '-mat', 'calflag');

end
