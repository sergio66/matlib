%[pse0,orig_slabs] = driver_sarta_cloud_rtp(h,hx,profsub,pattr,run_sarta);   %% code before vectorization
%[pse,orig_slabs]  = driver_sarta_cloud_rtp(h,hx,profsub,pattr,run_sarta);   %% code after vectorization
%[psex0,orig_slabs] = driver_sarta_cloud_rtp(h,hx,profsub,pattr,run_sarta);  %% trying to go back to code before vectorization

figure(1)
clf
subplot(221)
  plot(pse0.cpsize,pse.cpsize,'b.',pse0.cpsize2,pse.cpsize2,'r.',pse0.cpsize,pse0x.cpsize,'c.',pse0.cpsize2,pse0x.cpsize2,'m.'); title('cpsize')
subplot(222)
  plot(pse0.cfrac,pse.cfrac,'b.',pse0.cfrac2,pse.cfrac2,'r.',pse0.cfrac,pse0x.cfrac,'c.',pse0.cfrac2,pse0x.cfrac2,'m.'); title('cfrac')
subplot(223)
  plot(pse0.cngwat,pse.cngwat,'b.',pse0.cngwat2,pse.cngwat2,'r.',pse0.cngwat,pse0x.cngwat,'c.',pse0.cngwat2,pse0x.cngwat2,'m.'); title('cngwat')
subplot(224)
  plot(pse0.cprtop,pse.cprtop,'b.',pse0.cprtop2,pse.cprtop2,'r.',pse0.cprtop,pse0x.cprtop,'c.',pse0.cprtop2,pse0x.cprtop2,'m.'); title('cprtop')
  axis([0 1000 0 1000])

figure(2); clf
clf
subplot(221)
  plot(pse0.cpsize,psex0.cpsize,'b.',pse0.cpsize2,psex0.cpsize2,'r.',pse0.cpsize,pse0x.cpsize,'c.',pse0.cpsize2,pse0x.cpsize2,'m.'); title('cpsize')
subplot(222)
  plot(pse0.cfrac,psex0.cfrac,'b.',pse0.cfrac2,psex0.cfrac2,'r.',pse0.cfrac,pse0x.cfrac,'c.',pse0.cfrac2,pse0x.cfrac2,'m.'); title('cfrac')
subplot(223)
  plot(pse0.cngwat,psex0.cngwat,'b.',pse0.cngwat2,psex0.cngwat2,'r.',pse0.cngwat,pse0x.cngwat,'c.',pse0.cngwat2,pse0x.cngwat2,'m.'); title('cngwat')
subplot(224)
  plot(pse0.cprtop,psex0.cprtop,'b.',pse0.cprtop2,psex0.cprtop2,'r.',pse0.cprtop,pse0x.cprtop,'c.',pse0.cprtop2,pse0x.cprtop2,'m.'); title('cprtop')
  axis([0 1000 0 1000])
