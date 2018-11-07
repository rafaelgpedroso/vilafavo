local tm = {c=0}
local score = 0
local speed = 20

tm.i = 80000
tm.f = function()
	tm.t = event.timer(tm.i/8,function()
		if tm.c < 8 then
			tm.c = tm.c + 1
			tm.f()
		else
			finish()
		end
	end)
end

platform = obj:new('platform',7,{x=0,y=100,w=1280,h=414,yi={271,375,483},wi=503,i={},nr=0})
platform.draw = function()
	canvas:attrClip(0,platform.y,1280,platform.h)
	canvas:compose(platform.x,platform.y,gamebg)
	canvas:compose(platform.x+1280,platform.y,gamebg)
	canvas:compose(46,38,clkimg[9])
	
	for pl,_pl in pairs(platform.i) do
		canvas:compose(_pl.x,_pl.y-25,plimg)
	end

	canvas:attrClip(1112,36,118,139)
	canvas:compose(1112,36,mkimg)
	canvas:attrColor(117,27,37,255)
	text.set(90,14,14,'c')
	text.print(1125,31,score)
end

platform.create = function()
	local ch = {{2,3},{1,3},{1,2}}

	local r = ch[pllast][math.random(1,2)]
	platform.nr = platform.nr+1
	platform.i[platform.nr] = {r=r,x=1280,y=platform.yi[r]}
	
	pllast = r
	
	coin.create(r)
end

chr = obj:new('character',8,{x=455,y=589,w=121,h=169,c={y=550,h=98},yi=589,yj=135,fr=1,jp=false,bee=0})
chrimg = {canvas:new('img/mnop/char1.png'),canvas:new('img/mnop/char2.png'),canvas:new('img/mnop/char3.png')}

chr.clear = function()
	canvas:attrClip(chr.x,0,chr.w,720)
	canvas:attrColor(19,24,39,255)
	canvas:drawRect('fill',chr.x,0,chr.w,100)
	canvas:drawRect('fill',chr.x,514,chr.w,550)
	canvas:attrColor(81,92,102,255)
	canvas:drawRect('fill',chr.x,chr.c.y,chr.w,105)
end
chr.draw = function()
	canvas:attrClip(chr.x,chr.y-chr.h,chr.w,chr.h)
	canvas:compose(chr.x,chr.y-chr.h,chrimg[chr.fr])
end

chr.jump = function()
	if not chr.jp then
		chr.ypr = chr.y
		chr.jp = true
		chr.fr = 3
		play('jump',function(i,d)
			chr.y = chr.ypr - i/d * (i/d-2) * -chr.yj
			
			if chr.x+chr.w-10>=bee.x and chr.x<=bee.x+bee.w-10 and chr.y<=bee.y+80 and chr.y>=bee.y-45 then
				bee.get()
			end

		end,0,8,chr.fall)
	end
end

chr.fall = function()
	chr.fr = 3
	chr.jp = true
	chr.ypr = chr.y
	chr.yd = chr.yi - chr.ypr
	play('jumpout',function(i,d)
		y = chr.ypr + math.pow(i/d, 2) * chr.yd
		
		_pl = platform.i[plpos]
		if _pl then
			if chr.y<_pl.y and y>=_pl.y then
				stop('jumpout')
				chr.y = _pl.y
				chr.jp = false
			else
				chr.y = y
			end
		else			
			chr.y = y
		end
	end,0,8,function()
		chr.jp = false
	end)
end

bee = obj:new('bee',10,{x=-156,y=371,w=156,h=128,fr=1,fl=0})
beeimg = {canvas:new('img/mnop/bee1.png'),canvas:new('img/mnop/bee2.png')}

bee.clear = function()
	if bee.y<=228 then
		canvas:attrClip(bee.x,0,bee.w,100)
		canvas:attrColor(19,24,39,255)
		canvas:drawRect('fill',bee.x,0,bee.w,100)
	end
end
bee.draw = function()
	canvas:attrClip(bee.x,bee.y-bee.h,bee.w,bee.h)
	canvas:compose(bee.x,bee.y-bee.h,beeimg[bee.fr])
end

bee.flight = function()
	c = math.random(350,450)
	c = c - bee.y
	bee.ypr = bee.y

	bee.fl = 1
	play('fl1',function(i,d)
		bee.x = bee.x + 10
		bee.y = bee.ypr + i/d * (i/d-2) * - c
	end,0,12,function()

		c = 339
		c = bee.y - c
		bee.ypr = bee.y

		bee.fl = 2
		play('fl2',function(i,d)
			bee.y = bee.ypr - math.pow(i/d, 2) * c
			bee.x = bee.x + 10
		end,0,12,function()

			c = math.random(228,328)
			c = bee.y - c
			bee.ypr = bee.y

			bee.fl = 3
			play('fl3',function(i,d)
				bee.x = bee.x + 10
				bee.y = bee.ypr - i/d * (i/d-2) * - c
			end,0,12,function()
				
				c = 339
				c = c - bee.y
				bee.ypr = bee.y

				bee.fl = 4
				play('fl4',function(i,d)
					bee.y = bee.ypr + math.pow(i/d, 2) * c
					bee.x = bee.x + 10
				end,0,12,function()
					if bee.x>=1280 then
						bee:remove()
						bee.x, bee.y = -156,371
						bee.fl = 0
						beenext = math.random(100,180)
					else
						bee.flight()
					end
				end)
			end)
		end)
	end)
end

bee.get = function()
	stop('jump')
	if bee.fl > 0 then
		stop('fl'..bee.fl)
	end
	
	chr.fr = 2
	chr.y = bee.y+156
	bee.x = chr.x-8
	
	chr.bee = math.random(150,300)
	
	onKey('CURSOR_UP',function()
		if bee.y>150 then
			chr.y = chr.y - 25
			bee.y = bee.y - 25
		end
	end)
	onKey('CURSOR_DOWN',function()
		if chr.y<560 then
			chr.y = chr.y + 25
			bee.y = bee.y + 25
		end
	end)
end

coin = obj:new('coin',9,{x=300,y=300,w=45,h=50,i={},nr=0})
coinimg = canvas:new('img/mnop/coin.png')

coin.draw = function()
	for cn,_cn in pairs(coin.i) do
		canvas:attrClip(_cn.x,_cn.y-90,coin.w,coin.h)
		canvas:compose(_cn.x,_cn.y-90,coinimg)
	end
end

coin.create = function(r)
	local x = 1200
	for n=1,4 do
		x = x + 120
		if math.random(1,5)>2 then
			coin.nr = coin.nr+1
			coin.i[coin.nr] = {x=x,y=platform.yi[r]}
		end
	end
end

coin.get = function(cn)
	score = score + 1
	coin.i[cn] = nil
end

clk = obj:new('clk',11,{})
clk.draw = function()
	canvas:attrClip(46,38,136,134)
	canvas:compose(46,38,clkimg[9])
	if tm.c > 0 then
		canvas:compose(46,38,clkimg[tm.c])
	end
end

gameplay = function(i,d)
	local _plpos

	if platform.x<=-1280 then
		platform.x = 0
	else
		platform.x = platform.x - speed
	end
	
	plnext = plnext - speed
	
	if plnext<=0 then
		platform.create()
		plnext = math.random(503,850)
	end

	cnnext = cnnext - speed
	
	plpos = 0
	
	for pl,_pl in pairs(platform.i) do
		_pl.x = _pl.x - speed
		
		if _pl.x <= chr.x+chr.w and _pl.x>= chr.x-platform.wi then
			plpos = pl
		elseif _pl.x+platform.wi<0 then
			platform.i[pl] = nil
		end
	end

	for cn,_cn in pairs(coin.i) do
		_cn.x = _cn.x - speed
		if chr.x+chr.w-10>=_cn.x and chr.x<=_cn.x+coin.w-10 and chr.y<=_cn.y+80 and chr.y>=_cn.y-45   then
			coin.get(cn)
		end
	end
	
	if not chr.jp then
		chr.fr = alt(i,3,{1,2,3,2})
		
		_plpos = platform.i[plpos]
		if _plpos then
			if _plpos.y>chr.y or _plpos.y<chr.y and chr.y < chr.yi then
				chr.fall()
			end
		elseif chr.y < chr.yi then
			chr.fall()
		end
	end
	
	bee.fr = alt(i,1,2)

	if beenext>0 then
		beenext = beenext-1
		if beenext==1 then
			beenext = 0
			bee:add()
			bee.flight()
		end
	end
	
	if chr.bee>0 then
		chr.bee = chr.bee - 1
		if chr.bee==1 then
			chr.bee = 0
			bee.flight()
			chr.fall()

			speed = 20
			
			onKey('CURSOR_UP',function()
				chr.jump()
			end)
			onKey('CURSOR_DOWN',nil)
		end
	end
end

finish = function()
	onKey('CURSOR_DOWN',nil)
	onKey('CURSOR_UP',nil)
	onKey('CURSOR_LEFT',nil)
	onKey('CURSOR_RIGHT',nil)

	stop('run')
	chr:remove()

	wait(30,function()
		platform:remove()
		bee:remove()
		coin:remove()
		clk:remove()

		chrimg[1] = nil
		chrimg[2] = nil
		chrimg[3] = nil
		chrimg = nil
		beeimg[1] = nil
		beeimg[2] = nil
		beeimg = nil
		coinimg = nil
		gamebg = nil
		mkimg = nil
		plimg = nil
		
		imsg.msg = 'Muito bem! Você conquistou '..game.earn[1]..' em moedas e mais '..score..' em mel'
		imsg.draw()
		event.timer(2500,function()
			game.done()
			player.cash('h',score)
		end)
	end)
end

plpos = 0
plnext = 0
pllast = 3

cnnext = 0
beenext = math.random(100,180)

gamebg = canvas:new('img/mnop/bg.jpg')
mkimg = canvas:new('img/mnop/marker.png')
plimg = canvas:new('img/mnop/platform.png')

canvas:attrClip(0,0,1280,720)
canvas:attrColor(19,24,39,255)
canvas:drawRect('fill',0,0,1280,720)
canvas:attrColor(81,92,102,255)
canvas:drawRect('fill',0,550,1280,105)
canvas:compose(0,100,gamebg)

box.i = {'JOGO DAS OPERÁRIAS','Percorra as plataformas da fábrica coletando bônus em mel. Pule nas abelhas operárias para pegar uma carona e acelerar seu trabalho. Ganhe '..game.earn[3]..' em moedas e mais a quantidade de mel que coletar.'}
box.draw()

onKey('ENTER',function()
	onKey('ENTER',nil)

	canvas:attrClip(0,0,1280,720)
	canvas:attrColor(19,24,39,255)
	canvas:drawRect('fill',0,0,1280,720)
	canvas:attrColor(81,92,102,255)
	canvas:drawRect('fill',0,550,1280,105)
	canvas:compose(0,100,gamebg)

	platform:add()
	chr:add()
	coin:add()
	clk:add()

	tm.f()

	onKey('CURSOR_UP',function()
		chr.jump()
	end)

	play('run',function(i,d)
		gameplay(i,d)
	end,0)	
end)
