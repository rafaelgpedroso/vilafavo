-- PLACE -----------------------------------------------------------
--------------------------------------------------------------------

place = obj:new('place',1,{x=0,y=0,w=1280,h=720,base=nil,c={},b={},cl={a=true,xi=0,yi=0,xe=1280,ye=720},stopped=false})

place.draw = function()
	if place.cl.a then

		local w,h = place.cl.xe - place.cl.xi, place.cl.ye - place.cl.yi
		placebase:attrClip(place.cl.xi,place.cl.yi,w,h)

		street.draw()
		
		place.cars()
		
		for r=1,13 do
			for c=1,13 do
				if place.b[r] and place.b[r][c] then
					build.draw(place.b[r][c])
				end

				if place.c[r] and place.c[r][c] then
					car = place.c[r][c][1]
					cars.draw(car)
					car = place.c[r][c][2]
					cars.draw(car)
				end
			end
		end
		
		placebase:compose(0,0,placeimg)
		placebase:flush()
		
		canvas:attrClip(place.x+place.cl.xi,place.cl.yi,w,h)
		canvas:compose(place.x,place.y,placebase)
		
		place.cl = {a=false,xi=1280,yi=720,xe=0,ye=0}
	end
end

place.cars = function()
	local n,r,c

	place.c = {}

	for car,_car in pairs(cars.i) do
		r,c = street.coord(_car.st,_car.p)
		if not place.c[r] then
			place.c[r] = {}
		end
		if not place.c[r][c] then
			place.c[r][c] = {}
		end
		
		if _car.view=='H' and _car.dir==2 or _car.view=='V' and _car.dir==1 then
			n = 1
		else
			n = 2
		end
		
		place.c[r][c][n] = car
	end
end

place.clip = function(x,y)
	place.cl.a = true
	
	if x<place.cl.xi then
		place.cl.xi = x
	end
	if y<place.cl.yi then
		place.cl.yi = y
	end
	
	if x+cars.w>place.cl.xe then
		place.cl.xe = x+cars.w
	end
	if y+cars.h>place.cl.ye then
		place.cl.ye = y+cars.h
	end
end

place.create = function()
	placebase = nil
	placebase = canvas:new(place.w,place.h)
	placebase:compose(0,0,placeimg)
	
	street.s = {}
	street.s = street.create(level[player.hv].street)
	
	build.i = {}
	place.b = {}
	build.create(level[player.hv].build)
end

place.start = function()
	local free

	routes.i = {}
	routes.on = false

	street.cr = {}
	for r=1,13 do
		street.cr[r] = {}
		for c=1,13 do
			street.cr[r][c] = {stH=0,pH=0,stV=0,pV=0}
		end
	end
	
	street.build()

	routes.i = routes.create(level[player.hv].routes)
		
	routes.free = {}
	for route,_route in pairs(routes.i) do
		free = true
		for strt,_strt in pairs(_route) do
			if street.s[_strt.st].jam then
				free = false
			end
		end
		routes.free[route] = free
	end

	place.resume()
end

place.resume = function()
	build.img = {canvas:new('img/bd1.png'),canvas:new('img/bd2.png'),canvas:new('img/bd3.png'),canvas:new('img/bd4.png'),canvas:new('img/bd5.png'),canvas:new('img/bd6.png'),canvas:new('img/bd7.png'),canvas:new('img/bd8.png'),canvas:new('img/bd9.png'),canvas:new('img/bdd.png')}
	
	if #player.web>0 then
		if player.web[1]>0 then
			pcall(function()
				build.img[5] = canvas:new('http://www.fabiocardoso.com.br/inovapps/bd5'..player.web[1]..'.png')
			end)
		end
		if player.web[2]>0 then
			pcall(function()
				build.img[6] = canvas:new('http://www.fabiocardoso.com.br/inovapps/bd6'..player.web[2]..'.png')
			end)
		end
		if player.web[3]>0 then
			pcall(function()
				build.img[7] = canvas:new('http://www.fabiocardoso.com.br/inovapps/bd7'..player.web[3]..'.png')
			end)
		end
	end
	
	cars.img = {
		H = {
			{canvas:new('img/car11.png'),canvas:new('img/car12.png')},
			{canvas:new('img/car21.png'),canvas:new('img/car22.png')},
			{canvas:new('img/car31.png'),canvas:new('img/car32.png')},
			{canvas:new('img/car41.png'),canvas:new('img/car42.png')}
		},
		V = {
			{canvas:new('img/car13.png'),canvas:new('img/car14.png')},
			{canvas:new('img/car23.png'),canvas:new('img/car24.png')},
			{canvas:new('img/car33.png'),canvas:new('img/car34.png')},
			{canvas:new('img/car43.png'),canvas:new('img/car44.png')}
		}
	}

	routes.on = false

	place.cl={a=true,xi=0,yi=0,xe=1280,ye=720}
	cars.i = {}
	street.jam()

	place:add()
	routes.start()
end

place.stop = function()
	place.stopped = true

	ex.trans={}
	ex.waitc={}
	place:remove()
	
	build.img = nil
	cars.img = nil
	collectgarbage()
end


--------------------------------------------------------------------------------------------------------------------------------
-- BUILDINGS -------------------------------------------------------------------------------------------------------------------

build = {w=116,h=158,xi=62,yi=186,i={},img={},cursor={x=67,y=113}}
build.name = {'Vila','Fazenda','Escola','Fábrica','Mercado','Shopping','Parque','Estação','Trânsito'}

build.create = function(a)
	for k,v in pairs(a) do
		t = v[1]
		l = v[2]
		p = v[3]
		brw = v[4]
		brwx = v[5]
		dis = v.disable

		local x = build.xi + (11 - l + p-1) * street.xp
		local y = build.yi - (11 - l - p+1) * street.yp

		local jam = t==4 or t==5 or t==6 or t==8
		
		build.i[k] = {t=t,l=l,p=p,x=x,y=y,cursor={brw=brw,brwx=brwx},jam=jam,access=0,disable=dis}

		if not place.b[l] then
			place.b[l] = {}
		end
		place.b[l][p] = k
	end
end

build.draw = function(i)
	local _bd = build.i[i]

	if _bd.disable then
		placebase:compose(_bd.x,_bd.y,build.img[10])
	else
		placebase:compose(_bd.x,_bd.y,build.img[_bd.t])
	end
end

--------------------------------------------------------------------------------------------------------------------------------
-- STREET ----------------------------------------------------------------------------------------------------------------------

street = {x=120,y=0,w=1160,h=720,img={},xi=-58,yi=264,xp=58,yp=40,s={},cr={},cursor={x1=10,x2=106,y=56}}

street.create = function(streets)
	local st,_st
	local r = {}

	for st,_st in pairs(streets) do
		table.insert(r,{o=_st.o,l=_st.l,i=_st.i,e=_st.e,cursor=_st.cursor,cars={},jam=_st.jam,wait={},on=false,name=_st.name,bike=0,lnbus={},marker={_st.marker[1],_st.marker[2],_st.marker[3]},total=_st.total,implanted=_st.implanted})
	end
	return r
end

street.build = function()
	local x,y,n,fc,img,cr
	local st,_st

	streetbase = nil

	street.img = {H=canvas:new('img/stH.png'),V=canvas:new('img/stV.png'),N=canvas:new('img/stN.png'),R=canvas:new('img/stR.png')}
	street.img.fo = {H=canvas:new('img/sfoH.png'),V=canvas:new('img/sfoV.png')}
	street.img.co = {H=canvas:new('img/scoH.png'),V=canvas:new('img/scoV.png')}
	street.img.cf = {H=canvas:new('img/scfH.png'),V=canvas:new('img/scfV.png')}
	street.img.cv = {H=canvas:new('img/scvH.png'),V=canvas:new('img/scvV.png')}
	street.img.cursor = {H=canvas:new('img/stbt1.png'),V=canvas:new('img/stbt2.png')}
	
	streetbase = canvas:new(street.w,street.h)
	streetbase:attrColor(124,150,109,255)
	streetbase:drawRect('fill',0,0,street.w,street.h)
	
	for st,_st in pairs(street.s) do
		_improve = improve[player.hv].street[st] and improve[player.hv].street[st] or {}

		_st.cars = {}
		
		if _st.o=='H' then
			x = street.xi + (11-_st.l+_st.i-1) * street.xp
			y = street.yi - (11-_st.l-_st.i+1) * street.yp
		else
			x = street.xi + (9+_st.l-_st.i+1) * street.xp
			y = street.yi - (11-_st.l-_st.i+1) * street.yp
		end

		for n=_st.i,_st.e do
			cr = false
			_st.cars[n] = {}
			
			if _st.o=='H' then
				fc = 1
				img = street.img.H
				street.cr[_st.l][n].stH = st
				street.cr[_st.l][n].pH = n

				if street.cr[_st.l][n].stH>0 and street.cr[_st.l][n].stV>0 then
					cr = true
					img = street.img.N
				elseif (n==_st.e or n==_st.i) and n>1 and n<13 then
					img = street.img.R
				end
			else
				fc = -1
				img = street.img.V
				
				street.cr[n][_st.l].stV = st
				street.cr[n][_st.l].pV = n

				if street.cr[n][_st.l].stH>0 and street.cr[n][_st.l].stV>0 then
					cr = true
					img = street.img.N
				elseif (n==_st.e or n==_st.i) and n>1 and n<13 then
					img = street.img.R
				end
			end

			if n==_st.cursor.p then
				_st.cursor.x = _st.o=='H' and x+street.x+street.cursor.x1 or x+street.x+street.cursor.x2
				_st.cursor.y = y+street.cursor.y
				streetbase:compose(x,y,street.img.cursor[_st.o])
			end
			
			streetbase:compose(x,y,img)
			
			if not cr then
				if _improve[11] then
					streetbase:compose(x,y,street.img.co[_st.o])
				elseif _improve[10] then
					streetbase:compose(x,y,street.img.fo[_st.o])
				end
				if _improve[7] then
					streetbase:compose(x,y,street.img.cv[_st.o])
				elseif _improve[6] then
					streetbase:compose(x,y,street.img.cf[_st.o])
				end
			end
			
			x = x + street.xp * fc
			y = y + street.yp
		end
	end

	streetbase:flush()

	street.img = nil
	collectgarbage()
end

street.draw = function()
	placebase:compose(street.x,street.y,streetbase)

end

street.coord = function(st,pos)
	local r,c
	local _st = street.s[st]

	if _st.o=='H' then
		r, c = _st.l, pos
	else
		r, c = pos, _st.l
	end
	return r,c
end

street.corner = function(st,pos)
	local r,c = street.coord(st,pos)
	local vr = r>0 and r<14 and c>0 and c<14
	
	if vr and street.cr[r][c].stH>0 and street.cr[r][c].stV>0 then
		return street.cr[r][c]
	else
		return false
	end
end

street.ins = function(st,p,dir,car)
	if street.s[st] then
		if p>0 and p<14 then
			street.s[st].cars[p][dir] = car
		end
	else
		place.stop()
	end
end

street.jam = function()
	local cr,n
	local st,_st

	for st,_st in pairs(street.s) do
		if _st.jam then
			for n=_st.i,_st.e do
				cr = street.corner(st,n)
				if not cr then
					cars.create(st,1,n)
					cars.create(st,2,n)
				end
			end
		end
		_st.wait={}
	end
end

----------------------------------------------------------------------------------------------------------------------------------
-- CARS --------------------------------------------------------------------------------------------------------------------------

cars = {x=0,y=0,w=116,h=92,xi=62,yi=252,img={},i={},dur=20,wt=10}

cars.sort = {1,2,2,2,2,3,4}

cars.draw = function(car)
	local _car = cars.i[car]
	if _car then
		placebase:compose(_car.x,_car.y,cars.img[_car.view][_car.car][_car.dir])
	end
end

cars.pos = function(_car,p)
	local x,y
	local _st = street.s[_car.st]
	
	p = p and p or _car.pi
	
	if _car.view=='H' then
		x = cars.xi + (11 - _st.l + p-1) * street.xp
		y = cars.yi - (11 - _st.l - p+1) * street.yp
	else
		x = cars.xi + (9 + _st.l - p+1) * street.xp
		y = cars.yi - (11 - _st.l - p+1) * street.yp
	end
	
	return x, y
end

cars.create = function(st,dir,pos,bike)
	local _st = street.s[st]
	local car = #cars.i+1
	
	local nr = bike and 1 or 2
	local ctype = cars.sort[math.random(nr,7)]
	local _car = {car=ctype,view=_st.o,dir=dir,st=st,p=pos,pi=pos,pe=0,pl=1}
	
	cars.i[car] = _car
	_car.x, _car.y = cars.pos(_car)

	if not _st.cars[pos] then
		_st.cars[pos] = {}
	end
	_st.cars[pos][dir] = car

	return car
end

cars.move = function(car,pe,fe)
	local p
	local _car = cars.i[car]
	
	if _car then
		local _st = street.s[_car.st]
		
		_car.xi, _car.yi = _car.x, _car.y
		_car.pe = pe
		_car.xe, _car.ye = cars.pos(_car,_car.pe)
		
		play('move'..car..pe,function(i,d)
			place.clip(_car.x,_car.y)
			
			p = math.ceil(_car.pi + i/d * (_car.pe-_car.pi))
			_car.p = p
		
			_car.x = _car.xi + i/d * (_car.xe-_car.xi)
			_car.y = _car.yi + i/d * (_car.ye-_car.yi)
			
			place.clip(_car.x,_car.y)
		end,0,cars.dur,
		function()
			if fe then
				fe()
			end
		end)
	else
		place.stop()
	end
end

cars.jam = function(st,dir,p,fe)
	local pi, pe, fc, mv, cr, pcr, d
	local _st = street.s[st]
	
	if dir==1 then
		pi = _st.e
		pe = _st.i
		fc = 1
	else
		pi = _st.i
		pe = _st.e
		fc = -1
	end	
	
	if not p then
		p = pi
	end

	mv = p+fc

	cr = street.corner(st,p)
	
	if _st.wait[p] then
	
		if _st.o=='H' then
			pcr = cr.pV
		else
			pcr = cr.pH
		end
	
		local carwait = _st.wait[p]
		
		cars.turn(carwait.car,pcr,st,carwait.dir,carwait.pe,function()
			local _stprev = street.s[carwait.stprev]
			if _stprev.jam then
				cars.jam(carwait.stprev,carwait.dirprev,carwait.pi)
			end
			
			if fe then
				fe()
			end
		end)
		_st.wait[p] = nil
	else
		if cr then
			p = p-fc
		end
		
		if not _st.cars[p][dir] then
			p = p-fc
			mv = p+fc
		end
		
		if p==pe then
			cars.create(st,dir,p-fc)
		end		
		
		d = fc*-1
		
		if p*d<=pe*d then
			wait(cars.dur/2,function()
				cars.jam(st,dir,p-fc,fe)
			end,true)
		end

		local car = _st.cars[p][dir]
		cars.move(car,mv,function()
			street.ins(st,p,dir)
			cars.i[car].pi = mv
			cars.i[car].p = mv
			street.ins(st,mv,dir,car)

			if mv<1 or mv>13 then
				cars.i[car] = nil
			end
			
			if fe and p==pe then
				fe()
			end
		end)
	end
end

cars.turn = function(car,p,stnew,dirnew,pe,fe)
	local d, _car, stprev, _stprev, _stnew, dirprev, orientprev
	
	if cars.i[car] then
		_car = cars.i[car]
		stprev, _stprev = _car.st, street.s[_car.st]
		_stnew = street.s[stnew]
	
		dirprev = _car.dir
		orientprev = _car.view
	
		_car.xi, _car.yi = _car.x, _car.y

		if dirprev==dirnew and orientprev=='H' or dirprev~=dirnew and orientprev=='V' then
			d = dirprev==1 and -0.5 or 0.5
			_car.pe = p+d
		else
			_car.pe = p
		end
		
		_car.xe, _car.ye = cars.pos(_car,_car.pe)

		place.clip(_car.xi,_car.yi)
		
		play('turn'..car,function(i,d)
			place.clip(_car.x,_car.y)

			_car.p = math.ceil(_car.pi + i/d * (_car.pe-_car.pi))
			_car.x = _car.xi + i/d * (_car.xe-_car.xi)
			_car.y = _car.yi + i/d * (_car.ye-_car.yi)
			
			place.clip(_car.x,_car.y)
		end,0,cars.dur,
		function()
			_stprev.cars[_car.pi][_car.dir] = nil
			_car.pi = math.ceil(_car.pe)
			_stprev.cars[_car.pi][_car.dir] = car

			_car.st = stnew
			_car.view, _car.dir = _stnew.o, dirnew

			pi = dirnew==1 and _car.pe-1 or _car.pe+1
			if dirprev==dirnew and orientprev=='H' or dirprev~=dirnew and orientprev=='V' then
				d = dirnew==1 and -0.5 or 0.5
				_car.x, _car.y = cars.pos(_car,pe+d)
				pi = pe+d
			end

			place.clip(_car.xi,_car.yi)
			
			_car.xi, _car.yi = _car.x, _car.y
			_car.pe = pe
			_car.xe, _car.ye = cars.pos(_car,_car.pe)
			
			play('turn2'..car,function(i,d)
				place.clip(_car.x,_car.y)

				_car.p = math.ceil(pi + i/d * (pe-pi))
				_car.x = _car.xi + i/d * (_car.xe-_car.xi)
				_car.y = _car.yi + i/d * (_car.ye-_car.yi)
				
				place.clip(_car.x,_car.y)
			end,0,cars.dur,function()
				_stprev.cars[_car.pi][dirprev] = nil
				_car.pi = _car.pe
				_car.p = _car.pe
				_stnew.cars[_car.pi][dirnew] = car
				
				if fe then
					fe()
				end
			end)
		end)
	else
		place.stop()
	end
end


-- ROUTES --------------------------------------------------------------
------------------------------------------------------------------------

routes = {i={},on=false, stop=false}

routes.create = function(a)
	local st,dir,cr,cri,cre,pi,pe,stnext,route
	local r = {}
	
	for k,v in pairs(a) do
		dir = a[k][1][2]
		if dir==1 then	
			pi,cri = 0,0
		else
			pi,cri = 14,14
		end
		route = {}
		for n=1,#v do
			st=v[n][1]
			dir=v[n][2]
			cre=v[n][3]
			
			pe = dir==1 and cre-1 or cre+1
			
			if cri==0 or cri==14 then
				pi=cri
			end
			
			if cre==0 or cre==14 then
				pe=cre
			end		
			
			table.insert(route, {st=st,dir=dir,pi=pi,pe=pe,cri=cri,cre=cre})

			if v[n+1] then
				stnext = v[n+1][1]
				dirnext = v[n+1][2]
				if stnext==st then
					cri = cre
					pi = dir==1 and cre+1 or cre-1
				else
					cr = street.corner(st,cre)
					cri = street.s[st].o=='H' and cr.pV or cr.pH
					pi = dirnext==1 and cri+1 or cri-1
				end
			end		
		end
		table.insert(r,route)
	end

	return r
end

routes.f = function(route,n,car)
	local _route, _routeprev, _routenext, _st, _stprev, _stnext, fc, pe, round, wt
	local get = false

	if n<=#routes.i[route] then
		_route = routes.i[route][n]
		_st = street.s[_route.st]
		
		if n>1 then
			_routeprev = routes.i[route][n-1]
			_stprev = street.s[_routeprev.st]
		end
		if n<#routes.i[route] then
			_routenext = routes.i[route][n+1]
			_stnext = street.s[_routenext.st]
		end		

		if _st.jam then
			jam = false
			if n<#routes.i[route] then
				if _stnext.o==_st.o then
					routes.f(route,n+1)
				else
					if _stnext.jam then
						car = _st.cars[_route.pe][_route.dir]
						_stnext.wait[_routenext.cri] = {car=car,dir=_routenext.dir,pi=_route.pe,pe=_routenext.pi,stprev=_route.st,dirprev=_route.dir}
						routes.f(route,n+1)
					else
						car = _st.cars[_route.pe][_route.dir]
						
						cars.turn(car,_route.cre,_routenext.st,_routenext.dir,_routenext.pi,function()
							_st.cars[_route.pe][_route.dir] = nil
							
							cars.jam(_route.st,_route.dir,_route.pe)
							
							routes.f(route,n+1,car)
						end)
					end
				end
			else
				cars.jam(_route.st,_route.dir,nil,function()
					routes.on = false
				end)
			end		
		else
			if not car then
				car = cars.create(_route.st,_route.dir,_route.pi,routes.free[route])
			end
			_car = cars.i[car]

			if _car.view==_st.o then
				pe = _route.pe
				wt = cars.wt
			
				round = _routenext and _route.st==_routenext.st and _route.pi==_routenext.pe
				if round then
					pe = _route.cre
					wt = 0
				end
			
				cars.move(car,pe,function()
					street.ins(_route.st,_car.pi,_car.dir)
					_car.pi = pe
					_car.p = pe
					street.ins(_route.st,_car.pi,_car.dir,car)
					
					if _stnext then
						if round then
							if _car.view=='H' then
								_car.view='V'
								_car.dir=_car.dir==1 and 2 or 1
							else
								_car.view='H'
							end
						end
						
						if _stnext.jam then
							_stnext.wait[_routenext.cri] = {car=car,dir=_routenext.dir,pi=_route.pe,pe=_routenext.pi,stprev=_route.st,dirprev=_route.dir}
						end
					
						wait(wt, function()
							if round then
								_car.view=_stnext.o
								_car.dir=_routenext.dir
							end
							
							routes.f(route,n+1,car)
						end,true)
					else
						cars.i[car] = nil
						routes.on = false
					end
				end)
			else
				cars.turn(car,_routeprev.cre,_route.st,_route.dir,_route.pi,function()
					routes.f(route,n,car)
				end)
			end
		end
	end
end

routes.start = function()
	if place.stopped then
		place.stopped = false
	elseif not routes.on then
		local r = math.random(#routes.i)
		routes.on = true
		routes.f(r,1)
	end
	wait(30,routes.start,true)
end

bg = function()
	canvas:compose(place.x,place.y,placebase)
end
