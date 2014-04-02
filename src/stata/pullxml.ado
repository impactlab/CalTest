program define pullxml
 version 13
 args txt isstring length
 local len=length("`txt'")
 local name=trim(itrim("`txt'"))
 local name=subinstr("`name'"," ","",.)
 local name=subinstr("`name'","=","",.)
 local name=substr("`name'",1,25)
 if "`isstring'"==""  gen XML_`name'=real(subinstr(word(substr(xmldata,strpos(xmldata,"`txt'=")+`len'+1,10),1),char(34),"",.))
 else {
 	if "`length'"=="" gen XML_`name'=word(substr(xmldata,strpos(xmldata,"`txt'=")+`len'+1,25),1)
 	else gen XML_`name'=subinstr(substr(xmldata,strpos(xmldata,"`txt'=")+`len'+1,`length'),char(34),"",.)
}
end
