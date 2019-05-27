addpath /home/sergio/MATLABCODE/matlib/clouds/sarta/
addpath /home/sergio/MATLABCODE/matlib/clouds/TCC/

dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/';
dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/ECM_CLOUD_SARTA3/';
dirall = '/asl/data/rtp/rtprod_airs/2011/03/11/ERA_CLOUD/';

dirall = '/asl/s1/sergio/rtp/rtp_airicrad_v6/2018/10/31/';

for ii = 1 : 240
  fname = [dirall 'cloudy_airs_l1b_ecm_sarta_baum_ice.2011.03.11.' num2str(ii,'%03d') '.rtp'];
  fname = [dirall 'cloudy_airs_l1b_ecm_sarta3_baum_ice_modiswater.2011.03.11.' num2str(ii,'%03d') '.rtp'];
  fname = [dirall 'cloudy_airs_l1b_era_sarta_baum_ice.2011.03.11.' num2str(ii,'%03d') '.rtp'];

  fname = [dirall 'cloudy_airs_l1b_ecm_sarta_baum_ice.2018.10.31.' num2str(ii,'%03d') '.rtp'];
  if exist(fname)
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

     allcorr1(ii) = corr1;
     allcorr2(ii) = corr2;
     allcorr3A(ii) = corr3A;
     allcorr3B(ii) = corr3B;
  else
     allcorr1(ii) = NaN;
     allcorr2(ii) = NaN;
     allcorr3A(ii) = NaN;
     allcorr3B(ii) = NaN;
  end  
  figure(6); plot(1:ii,allcorr1,'b',1:ii,allcorr2,'g',1:ii,allcorr3A,'r',1:ii,allcorr3B,'m')
  pause(0.1)
end
