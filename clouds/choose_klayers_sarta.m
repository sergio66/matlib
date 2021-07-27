if ~isfield(run_sarta,'klayers_code')
  %run_sarta.klayers_code = '/asl/packages/klayers/Bin/klayers_airs'; 
  run_sarta.klayers_code = '/asl/packages/klayersV205/BinV201/klayers_airs';
end   
if ~isfield(run_sarta,'sartaclear_code')
  run_sarta.sartaclear_code = '/asl/packages/sartaV108_PGEv6/Bin/sarta_airs_PGEv6_postNov2003';
  run_sarta.sartaclear_code = '/asl/packages/sartaV108/BinV201/sarta_apr08_m140_wcon_nte';
  run_sarta.sartaclear_code = '/asl/packages/sartaV108/BinV201/sarta_apr08_m140_pge_v6_tunmlt';
  run_sarta.sartaclear_code = '/home/sergio/SARTA_CLOUDY/BinV201/xsarta_apr08_m140_iceGHMbaum_waterdrop_desertdust_slabcloud_hg3';
  run_sarta.sartaclear_code = '/home/chepplew/gitLib/sarta/bin/airs_l1c_2834_may19_prod_v2';
end
if ~isfield(run_sarta,'sartacloud_code')
  %run_sarta.sartacloud_code = '/asl/packages/sartaV108/Bin/sarta_apr08_m140_iceaggr_waterdrop_desertdust_slabcloud_hg3_wcon_nte';
  %run_sarta.sartacloud_code = '/asl/packages/sartaV108/BinV201/sarta_apr08_m140_iceaggr_waterdrop_desertdust_slabcloud_hg3_wcon_nte';
  run_sarta.sartacloud_code = '/asl/packages/sartaV108/BinV201/sarta_apr08_m140_iceaggr_waterdrop_desertdust_slabcloud_hg3_wcon_nte';
  run_sarta.sartacloud_code = '/home/sergio/SARTA_CLOUDY/BinV201/sarta_apr08_m140_iceGHMbaum_waterdrop_desertdust_slabcloud_hg3';
  run_sarta.sartacloud_code = '/home/sergio/SARTA_CLOUDY/BinV201/xsarta_apr08_m140_iceGHMbaum_waterdrop_desertdust_slabcloud_hg3';
  run_sarta.sartacloud_code = '/home/chepplew/gitLib/sarta/bin/airs_l1c_2834_cloudy_may19_prod_v3';
end
