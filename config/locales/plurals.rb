key = lambda{|n| n%10==1 && n%100!=11 ? :one : n%10>=2 && n%10<=4 && (n%100<10 || n%100>=20) ? :few : :other}
{:ru => {:i18n => {:plural => {:keys => [:one, :few, :other], :rule => key}}}}