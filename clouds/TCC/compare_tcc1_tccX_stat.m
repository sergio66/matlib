strWhich = input('compare stats1 vs statsX (X=''1'',''2'',''3A'',''3B'',''4A'',''4B'') : ');

eval(['allcorrX  = allcorr' strWhich ';']);
eval(['ratioX    = ratio' strWhich ';']);
eval(['stdratioX = stdratio' strWhich ';']);
eval(['biasX     = bias' strWhich ';']);
eval(['stdbiasX  = stdbias' strWhich ';']);

figure(1); plot(1:ii,allcorr1,'b',1:ii,allcorrX,'r'); title('corr1 <tccX,p.tcc>')
figure(1); plot(mean_lat,allcorr1,'b.',mean_lat,allcorrX,'r.'); title('corr1 <tcc1,p.tcc>')
  xlabel('latitude')

figure(2); 
  subplot(211); plot(mean_lat,ratio1,'b.',mean_lat,ratioX,'r.'); axis([-90 +90 0.75 2.00])
       ylabel('mean <tcc1/p.tcc>')
  subplot(212); plot(mean_lat,stdratio1,'b.',mean_lat,stdratioX,'r.'); axis([-90 +90 0 0.5])
       ylabel('std <tcc1/p.tcc>')
  xlabel('latitude')

figure(3); 
  subplot(211); plot(mean_lat,-bias1,'b.',mean_lat,-biasX,'r.'); axis([-90 +90 -0.25 +0.25])
       ylabel('mean <p.tcc-tcc1>')
  subplot(212); plot(mean_lat,stdbias1,'b.',mean_lat,stdbiasX,'r.'); axis([-90 +90 0 0.3])
       ylabel('std <p.tcc-tcc1>')
  xlabel('latitude')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
