addpath /home/sergio/MATLABCODE/matlib/clouds/sarta/
addpath /home/sergio/MATLABCODE/matlib/clouds/TCC/

clear all
for ii = 1 : 8
  figure(ii); clf; 
end

dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/';
dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/ECM_CLOUD_SARTA3/';
dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/ERA_CLOUD/';

dirall = '/asl/s1/sergio/rtp/rtp_airicrad_v6/2018/10/31/';

cumsum = 9999; %% default, strow
cumsum = -1;   %% option, aumann

fprintf(1,'testing cumsum = %6i \n',cumsum)

for ii = 1 : 240
  fname = [dirall 'cloudy_airs_l1b_ecm_sarta_baum_ice.2011.03.11.' num2str(ii,'%03d') '.rtp'];
  fname = [dirall 'cloudy_airs_l1b_ecm_sarta3_baum_ice_modiswater.2011.03.11.' num2str(ii,'%03d') '.rtp'];
  fname = [dirall 'cloudy_airs_l1b_era_sarta_baum_ice.2011.03.11.' num2str(ii,'%03d') '.rtp'];

  if cumsum == 9999
    fname = [dirall 'cloudy_airs_l1b_ecm_sarta_baum_ice.2018.10.31.' num2str(ii,'%03d') '.rtp'];
  elseif cumsum == -1
    fname = [dirall 'cloudy_airs_l1b_ecm_sarta_baum_ice.2018.10.31.' num2str(ii,'%03d') '_cumsum_-1.rtp'];
  end

  iExist = -1;
  if exist(fname)
    thedir = dir(fname);
    if thedir.bytes > 1e8
      iExist = +1;
    end
  end
  if iExist == 1
    [h,ha,p,pa] = rtpread(fname);

    tcc1 = tcc_method1(p);
    tcc2 = tcc_method2(p);
    [tcc3A,tcc3B] = tcc_method3(p);

figure(1); scatter_coast(p.rlon,p.rlat,10,tcc1); colormap jet; title('METHOD 1'); caxis([0 1])
figure(2); scatter_coast(p.rlon,p.rlat,10,tcc2); colormap jet; title('METHOD 2'); caxis([0 1])
figure(3); scatter_coast(p.rlon,p.rlat,10,tcc3A); colormap jet; title('METHOD 3A'); caxis([0 1])
figure(4); scatter_coast(p.rlon,p.rlat,10,tcc3B); colormap jet; title('METHOD 3B'); caxis([0 1])
figure(5); scatter_coast(p.rlon,p.rlat,10,p.tcc); colormap jet; title('ORIG'); caxis([0 1])

     [Y,I] = sort(p.tcc);
     figure(6); plot(p.tcc(I),tcc1(I),'b',p.tcc(I),tcc2(I),'g',p.tcc(I),tcc3A(I),'r',p.tcc(I),tcc3B(I),'m')
     addpath /home/sergio/MATLABCODE/NANROUTINES
     corr1 = linearcorrelation(p.tcc,tcc1);
     corr2 = linearcorrelation(p.tcc,tcc2);
     corr3A = linearcorrelation(p.tcc,tcc3A);
     corr3B = nanlinearcorrelation(p.tcc,tcc3B);
     %[corr1 corr2 corr3A corr3B]

     leni = find(p.landfrac < eps); leni = length(leni)
     mean_lat(ii) = mean(p.rlat);
     mean_lon(ii) = mean(p.rlon);
     mean_num_ocean(ii) = leni;

     allcorr1(ii) = corr1;
     allcorr2(ii) = corr2;
     allcorr3A(ii) = corr3A;
     allcorr3B(ii) = corr3B;

     ratio1(ii) = nanmean((tcc1 + eps)./(p.tcc + eps));   stdratio1(ii)  = nanstd((tcc1 + eps)./(p.tcc + eps));
     ratio2(ii) = nanmean((tcc2 + eps)./(p.tcc + eps));   stdratio2(ii)  = nanstd((tcc2 + eps)./(p.tcc + eps));
     ratio3A(ii) = nanmean((tcc3A + eps)./(p.tcc + eps)); stdratio3A(ii) = nanstd((tcc3A + eps)./(p.tcc + eps));
     ratio3B(ii) = nanmean((tcc3B + eps)./(p.tcc + eps)); stdratio3B(ii) = nanstd((tcc3B + eps)./(p.tcc + eps));

     bias1(ii) = nanmean(tcc1-p.tcc);   stdbias1(ii)  = nanstd(tcc1-p.tcc);
     bias2(ii) = nanmean(tcc2-p.tcc);   stdbias2(ii)  = nanstd(tcc2-p.tcc);
     bias3A(ii) = nanmean(tcc3A-p.tcc); stdbias3A(ii) = nanstd(tcc3A-p.tcc);
     bias3B(ii) = nanmean(tcc3B-p.tcc); stdbias3B(ii) = nanstd(tcc3B-p.tcc);
    
  else
     allcorr1(ii) = NaN;
     allcorr2(ii) = NaN;
     allcorr3A(ii) = NaN;
     allcorr3B(ii) = NaN;

     ratio1(ii) = NaN;      stdratio1(ii) = NaN;
     ratio2(ii) = NaN;      stdratio2(ii) = NaN;
     ratio3A(ii) = NaN;     stdratio3A(ii) = NaN;
     ratio3B(ii) = NaN;     stdratio3B(ii) = NaN;

     bias1(ii) = NaN;      stdbias1(ii) = NaN;
     bias2(ii) = NaN;      stdbias2(ii) = NaN;
     bias3A(ii) = NaN;     stdbias3A(ii) = NaN;
     bias3B(ii) = NaN;     stdbias3B(ii) = NaN;

     mean_lat(ii) = NaN;
     mean_lon(ii) = NaN;
     mean_num_ocean(ii) = NaN;

  end  
  figure(6); plot(1:ii,allcorr1,'b',1:ii,allcorr2,'g',1:ii,allcorr3A,'r',1:ii,allcorr3B,'m')
     ylabel('corr <tccX,p.tcc>')
  figure(7);
     subplot(211); plot(1:ii,ratio1,'b',1:ii,ratio2,'g',1:ii,ratio3A,'r',1:ii,ratio3B,'m')
       ylabel('<tccX/p.tcc>')
       ax = axis; axis([ax(1) ax(2)  0.75 1.25])
     subplot(212); plot(1:ii,stdratio1,'b',1:ii,stdratio2,'g',1:ii,stdratio3A,'r',1:ii,stdratio3B,'m')
       ylabel('std <tccX/p.tcc>')
       ax = axis; axis([ax(1) ax(2)  0 0.5])
  figure(8);
     subplot(211); plot(1:ii,-bias1,'b',1:ii,-bias2,'g',1:ii,-bias3A,'r',1:ii,-bias3B,'m')
     ylabel('<p.tcc-tccX>')
     subplot(212); plot(1:ii,stdbias1,'b',1:ii,stdbias2,'g',1:ii,stdbias3A,'r',1:ii,stdbias3B,'m')
     ylabel('std <p.tcc-tccX>')
  pause(0.1)
end

if cumsum == 9999
  save test_tcc_9999.mat allcorr* *ratio* *std* *bias* mean* ii
else
  save test_tcc_-1.mat allcorr* *ratio* *std* *bias* mean* ii
end

figure(1); plot(1:ii,allcorr1); title('corr1 <tccX,p.tcc>')
figure(1); plot(mean_lat,allcorr1,'.'); title('corr1 <tcc1,p.tcc>')
  xlabel('latitude')

figure(2); 
  subplot(211); plot(mean_lat,ratio1,'.'); axis([-90 +90 0.75 1.25])
       ylabel('mean <tcc1/p.tcc>')
  subplot(212); plot(mean_lat,stdratio1,'.'); axis([-90 +90 0 0.5])
       ylabel('std <tcc1/p.tcc>')
  xlabel('latitude')

figure(3); 
  subplot(211); plot(mean_lat,-bias1,'.'); axis([-90 +90 0 +0.1])
       ylabel('mean <p.tcc-tcc1>')
  subplot(212); plot(mean_lat,stdbias1,'.'); axis([-90 +90 0 0.1])
       ylabel('std <p.tcc-tcc1>')
  xlabel('latitude')

