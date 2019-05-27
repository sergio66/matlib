function tcc = tcc_method2(p0)

%% (A) this DOES NOT include exponential factor for cloud overlap ie very simple version of eqn 2.19 in 
%%% ECNMWF documentation recommended by Reima Erasmaa 9211-part-iv-physical-processes.pdf
 
[numlevs,numprof] = size(p0.cc);

for pp = 1 : length(p0.stemp)
  cc = p0.cc(:,pp);
  cc = p0.cc(2:numlevs,pp);  
  oneminus = 1-cc;
  gah = cumprod(oneminus);
  tcc(pp) = 1 - gah(end);
end

%%%%%%%%%%%%%%%%%%%%%%%%%

tcc(tcc > 1) = 1; tcc(tcc < 0) = 0;
