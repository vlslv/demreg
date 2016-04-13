pro test_dem_map

  ; Just make a model DEM
  ; fold through the responses to get the DN
  ; and give these DN to the code

  d1=1d22
  m1=7.0
  s1=0.1

  tt=5+findgen(125)/50.

  temps=10d^tt;[0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]*1e6
  logt0=alog10(temps)

  if (file_test('aia_resp.dat') eq 0) then begin
    tresp=aia_get_response(/temperature,/dn,/chianti,/noblend,/evenorm)
    save,file='aia_resp.dat',tresp
  endif else begin

    restore,file='aia_resp.dat'
  endelse

  idc=[0,1,2,3,4,6]

  logT=tresp.logte
  gdt=where(logt ge min(logt0) and logt le max(logt0),ngd)
  logt=logt[gdt]
  TRmatrix=tresp.all[*,idc]
  TRmatrix=TRmatrix[gdt,*]
  root2pi=sqrt(2.*!PI)
  dem_mod=(d1/(root2pi*s1))*exp(-(logT-m1)^2/(2*s1^2))
  dn_mod=dem2dn(logT, dem_mod, TRmatrix)

  dn=dn_mod.dn
  edn=0.1*dn

  dn2dem_pos_nb, dn, edn,TRmatrix,logt,temps,dem,edem,elogt,chisq,dn_reg,/timed;,/gloci,glcindx=[0,1,1,1,1,1]

  yr=d1*[1e-2,1e1]
  plot,logt,dem_mod,/ylog,chars=2,xtit='Log T', ytit='DEM [cm!U-5!NK!U-1!N]',yrange=yr,ystyle=17
  loadct,39,/silent
  for i=0,n_elements(logt0)-2 do oplot,logt0[i:i+1],dem[i]*[1,1],color=250
  demax=(dem+edem) < yr[1]
  demin=(dem-edem) > yr[0]

  for i=0,n_elements(logt0)-2 do oplot, mean(logt0[i:i+1])*[1,1],[demin[i],demax[i]],color=250

  stop
end