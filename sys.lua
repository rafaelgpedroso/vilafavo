step = 33

ex = {draw={},clear={},trans={},exec={},wait={},waitc={}}
keyset = {}

obj={
	new=function(self,name,z,attr)
		o = {name=name,z=z,add=self.add,remove=self.remove}
		for k,v in pairs(attr) do
			o[k] = v
		end
		ex.draw[z] = {}
		return o;
	end,
	add=function(self)
		ex.draw[self.z].f = self.draw
		if self.clear then
			ex.clear[self.z] = self.clear
		end
	end,
	remove=function(self)
		if ex.draw[self.z].f then
			ex.draw[self.z].f(true)
			ex.draw[self.z].f = nil
		end
		if ex.clear[self.z] then
			ex.clear[self.z] = nil
		end
	end
}

play=function(n,f,b,d,e)
	if d then
		ex.trans[n] = {i=0,f=f,b=b,d=d,e=e}
	else
		ex.exec[n] = {i=0,f=f,b=b}
	end
end

stop=function(n)
	ex.exec[n] = nil
	ex.trans[n] = nil
end

wait=function(t,f,c)
	if c then
		table.insert(ex.waitc,{t=t,f=f})
	else
		table.insert(ex.wait,{t=t,f=f})
	end
end

kr = function()
	a = event.uptime()

	
	for k,v in pairs(ex.clear) do
		v()
	end
	
	for k,v in pairs(ex.wait) do
		if v.t>0 then
			v.t = v.t-1
		else
			if v.f then
				v.f()
			end
			ex.wait[k] = nil
		end
	end
	
	for k,v in pairs(ex.waitc) do
		if v.t>0 then
			v.t = v.t-1
		else
			if v.f then
				v.f()
			end
			ex.waitc[k] = nil
		end
	end
	
	for k,v in pairs(ex.exec) do
		if v.b>0 then
			v.b = v.b-1
		else
			v.i = v.i + 1
			v.f(v.i)
		end
	end

	for k,v in pairs(ex.trans) do
		if v.b>0 then
			v.b = v.b-1
		else
			if v.i<v.d then
				v.i = v.i + 1
				v.f(v.i,v.d)
			else
				if v.e then
					v.e()
				end
				ex.trans[k] = nil
			end
		end
	end

	for k,v in pairs(ex.draw) do
		if v.f then
			v.f()
		end
	end
	
	canvas:flush()
	
	o = step-(event.uptime()-a)
	if(o<0) then o=0 end
	event.timer(o,kr)
end

imgLoad = function(i)
	if type(i)=='table' then
		r = {}
		for k,v in pairs(i) do
			r[k] = canvas:new('img/'..v)
		end
		return r
	else
		return canvas:new('img/'..i)
	end
end

alt = function(i,c,v)
	if type(v)=='table' then
		n = (i-1) % (c * #v)
		r = (n - n%c) / c +1
		return v[r]
	else
		n = (i-1) % (c * v)
		r = (n - n%c) / c +1
		return r
	end
end

evt = function(descr)
	local e = {class='ncl',type='attribution',name=descr,value=1}
	e.action = 'start'; event.post(e)
	e.action = 'stop' ; event.post(e)
end

---------------------------------------------------------------------------------
-- TEXT -------------------------------------------------------------------------
text = {w=0,h=0,sy='',cv=nil}
text.center = function(tx,w,cv)
	local wtx = cv:measureText(tx)
	return (w-wtx)/2
end

text.wrap = function(tx,w,cv)
	word = ""
	ln = {}
	
	if tx then
		for s in string.gmatch(tx, "([^%s]+)%s*") do
			if s == '#n' then
				ln[#ln+1] = word
				word = '#n'
			else
				measure = string.gsub(word..' '..s,'#n ','')
				tw,th = cv:measureText(measure)
				if tw>w then
					ln[#ln+1] = word
					word = s
				else
					word = word=='' and s or word..' '..s
				end
			end
		end
		ln[#ln+1] = word
	end
	return ln
end

text.set = function(w,s,h,sy,cv)
	text.w = w
	text.h = h
	text.sy = sy
	if cv then
		text.cv = cv
	else
		text.cv = canvas
	end
	text.cv:attrFont('Tiresias',s,'')
end

text.print = function(x,y,tx)
	local xt,yt = x,y

	tx = text.wrap(tx,text.w,text.cv)
	for k,v in pairs(tx) do
		if text.sy=='c' then
			xt =  x+text.center(v,text.w,text.cv)
			if #tx==1 then
				yt =  yt + text.h/2
			end
		end
		text.cv:drawText(xt,yt,v)
		yt = yt+text.h
	end	
end
---------------------------------------------------------------------------------

audio = {}
audio.play = function(name)
	if name and audio.name then
		audio.time()
		event.post({class='ncl', type='attribution', name=audio.name..'_'..name, action='start'})
		audio.name = name
	elseif name then
		event.post({class='ncl', type='attribution', name=name, action='start'})
		audio.name = name
	else
		event.post({class='ncl', type='attribution', name=audio.name, action='start'})
	end

	audio.time = event.timer(17000,function()
		audio.play()
	end)
end

-----------------------------------------------------------------------------------




onKey = function(key,f)
	keyset[key] = f
end

press = function(e)
    if e.class == 'key' and e.type == 'press' then
        if keyset[e.key] then
			keyset[e.key]()
		end
    end
end
event.register(press)

math.randomseed(os.time())

kr()