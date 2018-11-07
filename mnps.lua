local tm = {c=0}
local score = 0

tm.i = 30000
tm.f = function()
	tm.t = event.timer(tm.i/8,function()
		if tm.c < 8 then
			tm.c = tm.c + 1
			canvas:attrClip(46,38,136,134)
			canvas:compose(46,38,clkimg[9])
			canvas:compose(46,38,clkimg[tm.c])
			tm.f()
		else
			finish()
		end
	end)
end

canvas:attrClip(0,0,1280,720)
gamebg = canvas:new('img/mnps/bg.jpg')
canvas:compose(0,0,gamebg)
canvas:compose(46,38,clkimg[9])

local speed = 20
local m0,m1,m2 = 7,7,10
local hrdon = 14
local freq = 200

mt = m0+m1+m2
m0 = m0+m1
pos = 0

track = obj:new('track',7,{p=0,pi=0,tr={l={x=482,xi=482,xd=470},r={x=783,xi=783,xd=454},y=-41,yi=-41,yd=761,w=7,wi=24,wd=17,h=1,hi=3,hd=2}})
trackimg = canvas:new('img/mnps/trait.png')

track.draw = function()
	canvas:attrClip(track.tr.l.x,track.tr.y,track.tr.wi,track.tr.hi)
	canvas:compose(0,0,gamebg)
	canvas:attrClip(track.tr.r.x,track.tr.y,track.tr.wi,track.tr.hi)
	canvas:compose(0,0,gamebg)
	
	track.tr.y = track.tr.yi + math.pow(track.p / 1000, 3) * track.tr.yd
	track.tr.l.x = track.tr.l.xi - math.pow(track.p / 1000, 3) * track.tr.l.xd
	track.tr.r.x = track.tr.r.xi + math.pow(track.p / 1000, 3) * track.tr.r.xd
	track.tr.w = track.tr.wi - track.tr.wd + math.pow(track.p / 1000, 3) * track.tr.wd
	track.tr.h = track.tr.hi - track.tr.hd + math.pow(track.p / 1000, 3) * track.tr.hd
	pcall(function()
		trackimg:attrScale(track.tr.w,track.tr.h)
	end)
	
	canvas:attrClip(track.tr.l.x,track.tr.y,track.tr.w,track.tr.h)
	canvas:compose(track.tr.l.x,track.tr.y,trackimg)
	canvas:attrClip(track.tr.r.x,track.tr.y,track.tr.w,track.tr.h)
	canvas:compose(track.tr.r.x,track.tr.y,trackimg)
end

truck = obj:new('truck',9,{x=530,y=436,xi={177,522,890},w=220,h=230,fr=1,an=2,on=1,move=false})
truckimg = {
	{canvas:new('img/mnps/trk11.png'),canvas:new('img/mnps/trk12.png'),canvas:new('img/mnps/trk13.png'),},
	{canvas:new('img/mnps/trk21.png'),canvas:new('img/mnps/trk22.png'),canvas:new('img/mnps/trk23.png'),},
	{canvas:new('img/mnps/trk31.png'),canvas:new('img/mnps/trk32.png'),canvas:new('img/mnps/trk33.png'),},
}	
	
truck.clear = function()
	if gamebg then
		canvas:attrClip(truck.x,truck.y,truck.w,truck.h)
		canvas:compose(0,0,gamebg)
	end
end
truck.draw = function()
	if truck.on==1 then
		truck.x = truck.xi[truck.an]
		canvas:attrClip(truck.x,truck.y,truck.w,truck.h)
		canvas:compose(truck.x,truck.y,truckimg[truck.an][truck.fr])
	end
end
truck.collide = function(hrd)
	if hurdle.i[hrd].t<4 then
		gamestop()
		play('collide',function(i,d)
			truck.on = alt(i,7,2)
		end,0,55)
		
		wait(70,gameplay)
	else
		hurdle.get(hrd)
	end

end

hurdle = obj:new('hurdle',8,{xi={500,602,707},xd={-414,-100,215},yi=-41,yd=761,wi=306,wd=238,hi=185,hd=144,i={},hn=0,lastp=0})
hurdleimg = {canvas:new('img/mnps/hrd1.png'),canvas:new('img/mnps/hrd2.png'),canvas:new('img/mnps/hrd3.png'),canvas:new('img/mnps/coin.png')}
	
hurdle.draw = function()
	local hrd,_hrd

	for hrd,_hrd in pairs(hurdle.i) do
		canvas:attrClip(_hrd.x,_hrd.y,_hrd.w,_hrd.h)
		canvas:compose(0,0,gamebg)

		_hrd.x = hurdle.xi[_hrd.an] + math.pow(_hrd.p / 1000, 3) * hurdle.xd[_hrd.an]
		_hrd.y = hurdle.yi + math.pow(_hrd.p / 1000, 3) * hurdle.yd
		_hrd.w = hurdle.wi - hurdle.wd + math.pow(_hrd.p / 1000, 3) * hurdle.wd
		_hrd.h = hurdle.hi - hurdle.hd + math.pow(_hrd.p / 1000, 3) * hurdle.hd

		pcall(function()
			hurdleimg[_hrd.t]:attrScale(_hrd.w,_hrd.h)
		end)
		canvas:attrClip(_hrd.x,_hrd.y,_hrd.w,_hrd.h)
		canvas:compose(_hrd.x,_hrd.y,hurdleimg[_hrd.t])
	end
end

hurdle.get = function(hrd)
	_hrd = hurdle.i[hrd]
	canvas:attrClip(_hrd.x,_hrd.y,_hrd.w,_hrd.h)
	canvas:compose(0,0,gamebg)
	hurdle.i[hrd] = nil

	score = score + 1

	result()
	
	if speed<80 then
		speed = speed + 0.2
	end
end

hurdle.create = function(t)
	local ch = {{2,3},{1,3},{1,2}}
	local rnd
	
	if t==2 then
		t = math.random(1,3)
		if hurdle.lastp==0 then		
			an = math.random(1,3)
		else
			rnd = math.random(1,2)
			an = ch[hurdle.lastp][rnd]
		end
		hurdle.lastp = an
	else
		t = 4
		an = hurdle.hnp
		if an==hurdle.lastp then
			hurdle.lastp = 0
		end
	end
	table.insert(hurdle.i,{t=t,an=an,pi=pos,x=hurdle.xi[1],y=hurdle.yi,w=68,h=41,})
end

gameplay = function()
	truck.on = 1
	hurdle.i = {}
	hurdle.on = 400

	canvas:attrClip(0,0,1280,720)
	canvas:compose(0,0,gamebg)
	result()

	truck.move = true
	play('run',function(i,d)
		truck.fr = alt(i,3,3)
		
		if track.p>= 1000 then
			track.p = 0
		else
			track.p = track.p + speed
		end
		
		pos = pos + speed

		hurdle.on = hurdle.on-speed
		
		if hurdle.on<=0 then
			if hurdle.hn==0 then
				rnd = math.random(1,mt)
				if rnd<m1 then
					hurdle.hn = rnd
					hurdle.hnp = math.random(1,3)
				end
			end
			
			if hurdle.hn>0 then
				hurdle.create(1)
				hurdle.hn = hurdle.hn - 1
			elseif rnd>m0 then
				hurdle.create(2)
			end
			hurdle.on = freq
		end
		
		for hrd,_hrd in pairs(hurdle.i) do
			_hrd.p = pos-_hrd.pi
			
			if _hrd.p>820 and _hrd.p<900 and _hrd.an==truck.an then
				truck.collide(hrd)
			end
			
			if _hrd.p>1100 then
				_hrd=nil
			end
		end
	end,0)
end

gamestop = function()
	truck.move = false
	stop('run')
end

result = function()
	canvas:attrColor(255,236,193,255)
	canvas:attrClip(1125,40,90,14)
	canvas:drawRect('fill',1125,40,90,14)

	canvas:attrColor(117,27,37,255)
	text.set(90,14,14,'c')
	text.print(1125,31,score)
end

finish = function()
	gamestop()
	onKey('CURSOR_LEFT',nil)
	onKey('CURSOR_RIGHT',nil)

	wait(15,function()
		hurdle:remove()
		truck:remove()
		track:remove()

		imsg.msg = 'Muito bem! Você conquistou '..game.earn[2]..' em moedas e mais '..score..' em mel'
		imsg.draw()
		wait(60,function()
			gamebg = nil
			trackimg = nil
			truckimg[1][1] = nil
			truckimg[1][2] = nil
			truckimg[1][3] = nil
			truckimg[2][1] = nil
			truckimg[2][2] = nil
			truckimg[2][3] = nil
			truckimg[3][1] = nil
			truckimg[3][2] = nil
			truckimg[3][3] = nil
			hurdleimg[4] = nil
			hurdleimg[4] = nil
			hurdleimg[4] = nil
			hurdleimg[4] = nil
			game.done()
			player.cash('h',score)
		end)
	end)
end

box.i = {'RUA DO PÓLEN','Dirija pela Rua do Pólen desviando dos obstáculos e recolhendo bônus em mel. Ganhe '..game.earn[1]..' em moedas e mais a quantidade de mel que conseguir coletar.'}
box.draw()

onKey('ENTER',function()
	onKey('ENTER',nil)
	canvas:compose(0,0,gamebg)

	hurdle:add()
	truck:add()
	track:add()

	tm.f()

	onKey('CURSOR_LEFT',function()
		if truck.an>1 and truck.move then
			truck.an = truck.an -1
		end
	end)
	onKey('CURSOR_RIGHT',function()
		if truck.an<3 and truck.move then
			truck.an = truck.an +1
		end
	end)

	gameplay()
end)


