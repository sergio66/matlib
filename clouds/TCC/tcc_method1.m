%{
(Andy Tangborn) I found a paper on the ECMWF cloud physics (maximum random
overlap; Jakob, et al , 1999 in QJRMS).  They use the following
algorithm (where Ck is the cloud fraction from the kth layer to the
TOA, ak is the cloud fraction for a single layer k):
  Ck = 1 -(1-C_{k-1} [ 1 - max(a_{k-1},a_{k})]/[1 - min(a_{k-1}, 1-delta)]
  for k=2:n_levels.
  init cond : for k=1, c1=a1.
  where delta = 0.000001
%}

function tcc = tcc_method1(p0)

delta = 0.000001;
for nn = 1 : p0.nlevs(1)
  an = p0.cc(nn,:);
  if nn == 1
    cn = an;
  else
    an_1 = p0.cc(nn-1,:);
    bnum = 1 - max(an,an_1);
    bden = 1 - min(an_1,1-delta);
    cn = 1 - (1-cn).*bnum./bden;
  end
end
tcc = cn;

tcc(tcc > 1) = 1; tcc(tcc < 0) = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%
