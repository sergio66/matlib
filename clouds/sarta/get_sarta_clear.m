function prof = get_sarta_clear(h,ha,prof0,pa,run_sarta)

tic

%% these are required but user needs to add them before using this code
%% addpath /asl/matlib/aslutil/

prof = prof0;

disp(' ')
fprintf(1,'  doing clear sky SARTA calcs ....\n')
fprintf(1,'    sarta clear = %s \n',run_sarta.sartaclear_code);

klayers = run_sarta.klayers_code;
sarta   = run_sarta.sartaclear_code;

if ~exist(klayers,'file')
  error('klayers exec done not exist')
end
if ~exist(sarta,'file')
  error('sarta cloud exec done not exist')
end

fip = mktempS('temp.ip.rtp');
fop = mktempS('temp.op.rtp');
frp = mktempS('temp.rp.rtp');
ugh = mktempS('ugh');

rtpwrite(fip,h,ha,prof,pa);
klayerser = ['!' klayers ' fin=' fip ' fout=' fop ' >& ' ugh];
  eval(klayerser);
try
  [headRX2 hattrR2 profRX2 pattrR2] = rtpread(fop);
catch me
  me
  fprintf(1,'oops : error running klayers, look at error log %s \n',ugh);
  %keyboard
  error('woof! try again!')
end

sartaer = ['!' sarta ' fin=' fop ' fout=' frp ' >& ' ugh];
  eval(sartaer);
try
  [headRX2 hattrR2 profRX2 pattrR2] = rtpread(frp);
catch me
  me
  fprintf(1,'oops : error running sarta clear, look at error log %s \n',ugh);
  %keyboard
  error('woof! try again!')
end

rmer = ['!/bin/rm ' fip ' ' fop ' ' frp ' ' ugh]; eval(rmer);

toc
prof.sarta_rclearcalc = profRX2.rcalc;
