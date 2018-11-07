-- CONTROL ------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

control = obj:new('control',3,{x=1045,y=34,w=195,h=274,clk={x=39},happiness={x2=108,y=104,w=85,h=16},img={}})
meters = {x=1053,y=164,w=179,h=148,display={w=52},honey={x=32,y=-9},coin={x=97,y=-9},pollution={x=4,y=73},accident={x=66,y=73},jam={x=127,y=73}}

control.draw = function()
	local w,jam

	canvas:attrClip(control.x,control.y,control.w,control.h)
	bg()
	
	canvas:compose(control.x+49,control.y+11,controlimg.m1)
	canvas:compose(control.x+2,control.y+control.happiness.y,controlimg.bar)

	if player.happ>50 then
		w = (player.happ-50)/50 * control.happiness.w
		canvas:attrColor(142,168,43,255)
		canvas:drawRect('fill',control.x+control.happiness.x2,control.y+control.happiness.y,w,control.happiness.h)
	else
		w = player.happ/50 * control.happiness.w
		canvas:attrColor(151,44,49,255)
		canvas:drawRect('fill',control.x+w+2,control.y+control.happiness.y,control.happiness.w-w,control.happiness.h)
	end
	canvas:compose(control.x,control.y,controlimg.m)

	canvas:compose(meters.x,meters.y,controlimg.meters)
	
	canvas:attrColor(101,33,41,255)

	text.set(meters.display.w,12,14,'c')
	text.print(meters.x+meters.honey.x,meters.y+meters.honey.y,string.sub(player.honey,1,6))
	text.print(meters.x+meters.coin.x,meters.y+meters.coin.y,string.sub(player.coin,1,6))
	
	text.print(meters.x+meters.pollution.x,meters.y+meters.pollution.y,math.floor((100-player.pollution)*0.4))
	text.print(meters.x+meters.accident.x,meters.y+meters.accident.y,math.floor((100-player.accident)*0.3))
	jam = player.stjam and (100-player.jam)*0.7 or (100-player.jam)*0.2
	text.print(meters.x+meters.jam.x,meters.y+meters.jam.y,math.floor(jam))
	
	if player.hplus.t>0 then
		player.hplus.t = player.hplus.t-1
		
		canvas:compose(1090,151,controlimg.cash)
	
		canvas:attrColor(248,217,132,255)
		text.set(meters.display.w,12,14,'c')
		text.print(meters.x+meters.honey.x,meters.y+meters.honey.y-12,player.hplus.v)
	end
	if player.cplus.t>0 then
		player.cplus.t = player.cplus.t-1

		canvas:compose(1153,151,controlimg.cash)
	
		canvas:attrColor(248,217,132,255)
		text.set(meters.display.w,12,14,'c')
		text.print(meters.x+meters.coin.x,meters.y+meters.coin.y-12,player.cplus.v)
	end
end


-- TIMER -----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

timer = {}
timer.continue = true

timer.t = function() end

timer.stop = function()
	timer.t()
end

timer.start = function()
	timer.on()
end

timer.on = function()
	timer.t = event.timer(player.day,function()
		player.cash('h',player.salary)
		player.decr = player.decr + 0.3

		player.control()
		
		if player.cinf<0 then
			wait(20,function()
				player.cash('h',player.cinf)
			end)
		end
		timer.on()
	end)
end


-- BUTTONS -----------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------

buttons = obj:new('buttons',2,{x=42,yi=14,yp=218,w=221,h=218,i={},sel=0,icon={x=56,y=46},tx={x=51,y=147},ex={x=1095,y=634,w=100,h=86}})
buttons.i = {
	{lb='INVESTIR',cursor={}},
	{lb='MINI GAMES',cursor={}},
	{lb='NOTIFICAÇÕES',cursor={}},
	{lb='',cursor={}}
}

buttons.draw = function()
	canvas:attrClip(cursor.xpr,cursor.ypr,cursor.w,cursor.h)
	bg()

	y = buttons.yi
	for k=1,3 do
		canvas:attrClip(buttons.x,y,buttons.w,buttons.h)
		bg()
		canvas:compose(buttons.x,y,buttonsimg.bt)
		canvas:compose(buttons.x+buttons.icon.x,y+buttons.icon.y,buttonsimg.icon[k])
		canvas:compose(buttons.x+buttons.tx.x,y+buttons.tx.y,buttonsimg.tx[k])
		if k==buttons.sel then
			canvas:compose(buttons.x,y,buttonsimg.hr)
		end
		
		y = y+buttons.yp
	end

	canvas:attrClip(buttons.ex.x,buttons.ex.y,buttons.ex.w,buttons.ex.h)
	bg()
	if buttons.sel==4 then
		canvas:compose(buttons.ex.x,buttons.ex.y,exhr)
	end

	if not cursor.hidden then
		canvas:attrClip(cursor.x,cursor.y,cursor.w,cursor.h)
		canvas:compose(cursor.x,cursor.y,cursorimg)
		cursor.xpr,cursor.ypr = cursor.x,cursor.y
	end
end

buttons.cursor = function()
	local rbrw = level[player.hv].buttons.rbrw

	buttons.i[1].cursor.brw = {{t=0,i=0},rbrw[1],{t=3,i=2},{t=0,i=0}}
	buttons.i[2].cursor.brw = {{t=3,i=1},rbrw[2],{t=3,i=3},{t=0,i=0}}
	buttons.i[3].cursor.brw = {{t=3,i=2},rbrw[3],{t=0,i=0},{t=0,i=0}}
	buttons.i[4].cursor.brw = {rbrw[4],{t=0,i=0},{t=0,i=0},rbrw[5]}
	
	cursor.sel.t = 1
	cursor.sel.i = 1
	cursor.x, cursor.y = cursor.pos(1,1)
	cursor.xi, cursor.yi = cursor.x, cursor.y
	cursor.xpr, cursor.ypr = cursor.x, cursor.y
	
	buttons.sel = 0
end


-- CURSOR ----------------------------------------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------------------------------------------------

cursor = obj:new('cursor',5,{x=0,xpr=0,xi=0,y=0,ypr=0,yi=0,w=63,h=63,img={},sel={t=0,i=0},active=false,hidden=true})

cursor.pos = function(t,i)
	if t==1 then
		return street.s[i].cursor.x, street.s[i].cursor.y
	elseif t==2 then
		return build.i[i].x+build.cursor.x, build.i[i].y+build.cursor.y
	else
		if i==4 then
			return buttons.ex.x + 40, buttons.ex.y + 18
		else
			return buttons.x + buttons.w -70, buttons.yi + i * buttons.yp -50
		end
	end
end

cursor.browse = function(a)
	local t,i
	if not cursor.active then
		if cursor.sel.t==1 then
			t,i = street.s[cursor.sel.i].cursor.brw[a].t,street.s[cursor.sel.i].cursor.brw[a].i
		elseif cursor.sel.t==2 then
			t,i = build.i[cursor.sel.i].cursor.brw[a].t,build.i[cursor.sel.i].cursor.brw[a].i
		else
			t,i = buttons.i[cursor.sel.i].cursor.brw[a].t,buttons.i[cursor.sel.i].cursor.brw[a].i
			if t>0 and t<3 then
				buttons.sel = 0
			end
		end
		
		if t>0 and i>0 then
			painel:remove()
			painel.on = false
			
			local xe,ye = cursor.pos(t,i)
			local xd,yd = xe-cursor.xi, ye-cursor.yi

			cursor.active = true
			play('cursor',function(i,d)
				cursor.x = cursor.xi + i/d * xd
				cursor.y = cursor.yi + i/d * yd
			end,0,6,function()
				cursor.sel.i = i
				cursor.sel.t = t
				cursor.xi, cursor.yi = cursor.x, cursor.y
				cursor.active = false

				cursor.enter()
				if t<3 then
					wait(12,function()
						painel.show(i)
					end)
				end
			end)
		end
	end
end

cursor.browsex = function(a,excl)
	local t,i
	local brw = excl and 'brwx' or 'brw'
	
	if not cursor.active then
		if cursor.sel.t==1 then
			t,i = street.s[cursor.sel.i].cursor[brw][a].t,street.s[cursor.sel.i].cursor[brw][a].i
		elseif cursor.sel.t==2 then
			t,i = build.i[cursor.sel.i].cursor[brw][a].t,build.i[cursor.sel.i].cursor[brw][a].i
		end
		
		if t==3 then
			t=0
		end
		
		if t>0 and i>0 then
			imsg.msg = ''
			imsg:remove()

			painel:remove()
			painel.on = false

			local xe,ye = cursor.pos(t,i)
			local xd,yd = xe-cursor.xi, ye-cursor.yi

			cursor.active = true
			play('cursor',function(i,d)
				cursor.x = cursor.xi + i/d * xd
				cursor.y = cursor.yi + i/d * yd
			end,0,6,function()
				cursor.sel.i = i
				cursor.sel.t = t
				cursor.xi, cursor.yi = cursor.x, cursor.y
				cursor.active = false
				painel.show(i)
			end)
		end
	end
end

cursor.enter = function()
	if cursor.sel.t==3 then
		buttons.sel = cursor.sel.i
		if cursor.sel.i==4 then
			onKey('ENTER',function()
				imsg:remove()
				player.close()
				map.on()
			end)
		else
			onKey('ENTER',function()
				cursor.hidden = true
				place.stop()
				menu.start()
			end)
		end
	else
		onKey('ENTER',function()
			if painel.on then
				painel:remove()
				painel.on = false
			else
				painel.show(cursor.sel.i)
			end
		end)
	end
end

cursor.start = function()
	cursor.hidden = false
	onKey('CURSOR_UP',function()
		cursor.browse(1)
	end)
	onKey('CURSOR_DOWN',function()
		cursor.browse(3)
	end)
	onKey('CURSOR_RIGHT',function()
		cursor.browse(2)
	end)
	onKey('CURSOR_LEFT',function()
		cursor.browse(4)
	end)
	cursor.enter()
end

game = {file={'mnhc.lua','mnps.lua','mnop.lua'},earn={75,150,100},img={},i=0}
game.start = function(i)
	skip.on = false
	player.close()
	timer.stop()

	audio.play('mn')

	onKey('ENTER',nil)
	onKey('CURSOR_DOWN',nil)
	onKey('CURSOR_UP',nil)
	onKey('CURSOR_LEFT',nil)
	onKey('CURSOR_RIGHT',nil)
	
	dofile(game.file[i])
	game.i = i
end

game.done = function(i)
	audio.play('bg')

	skip.on = true

	player.open()
	timer.start()

	buttons.cursor()
	cursor.start()
	
	player.cash('c',game.earn[game.i])
	game.i = 0
end


-- PAINEL -------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

painel = obj:new('painel',4,{x=400,y=260,w=271,h=361,h2=280,img={},bd={y=52,h=298,h2=217},ft={y=350,y2=269},ln={y1=173,y2=254},tl={x=12,y=21,w=255},traffic={x=80,x2=98,y=58},auto={x=146,y=86},bike={x=162,y=114},accident={x=167,y=142},busln={yt=181,x1=12,x2=136,y1=204,y2=227},access={x=126,y=86},stamp={x=17,xp=52,y1=262,y2=181,yp=48},on=false})

painel.create = function()
	painelbase = canvas:new(painel.w,painel.h)

	painelbase:compose(0,0,painelimg.hd)
	painelbase:compose(0,painel.ft.y,painelimg.ft)
	
	for y=painel.bd.y,painel.bd.y+painel.bd.h do
		painelbase:compose(0,y,painelimg.bd)
	end
	
	painelbase:compose(0,painel.ln.y1,painelimg.ln)
	painelbase:compose(0,painel.ln.y2,painelimg.ln)
	
	painelbase:flush()

	
	painelbase2 = canvas:new(painel.w,painel.h)

	painelbase2:compose(0,0,painelimg.hd)
	painelbase2:compose(0,painel.ft.y2,painelimg.ft)
	
	for y=painel.bd.y,painel.bd.y+painel.bd.h2 do
		painelbase2:compose(0,y,painelimg.bd)
	end
	
	painelbase2:compose(0,painel.ln.y1,painelimg.ln)
	
	painelbase2:flush()
end

gradient = function(v)
	local ri,rd = 208,-13
	local gi,gd = 119,101
	local bi,bd = 131,-62
	
	local r = ri + v/100 *rd
	local g = gi + v/100 *gd
	local b = bi + v/100 *bd

	if not r or r<0 then
		r = 0
	elseif r>255 then
		r = 255
	end
	if not g or g<0 then
		g = 0
	elseif r>255 then
		g = 255
	end
	if not b or b<0 then
		b = 0
	elseif r>255 then
		b = 255
	end

	return r, g, b
end

painel.draw = function(clear)
	local jam,r,g,b,_improve,x,y,yi,n
	
	canvas:attrClip(painel.x,painel.y,painel.w,painel.h)
	bg()
	
	if not clear then
		if cursor.sel.t==1 then
			canvas:compose(painel.x,painel.y,painelbase)

			local _st = level[player.hv].street[cursor.sel.i]
			
			if _st then	
				canvas:attrColor(239,216,136,255)
				text.set(painel.tl.w,16,17,'c')
				text.print(painel.x+painel.tl.x,painel.y+painel.tl.y-10,_st.name)

				text.set(painel.tl.w,16,17)
				if improve[1].itens[5] then
					text.print(painel.x+painel.tl.x,painel.y+painel.traffic.y,'Tráfego:')
					text.print(painel.x+painel.tl.x,painel.y+painel.auto.y,'Fluxo Automotor:')
					text.print(painel.x+painel.tl.x,painel.y+painel.bike.y,'Fluxo de Bicicletas:')
					text.print(painel.x+painel.tl.x,painel.y+painel.accident.y,'Índice de Acidentes:')

					if _st.jam then
						jam = 'RUIM'
						canvas:attrColor(208,119,131,255)
					else
						jam = 'BOM'
						canvas:attrColor(195,220,69,255)
					end
					text.print(painel.x+painel.traffic.x,painel.y+painel.traffic.y,jam)
					
					r,g,b = gradient(100-_st.marker[1])
					canvas:attrColor(r,g,b,255)
					text.print(painel.x+painel.auto.x,painel.y+painel.auto.y,math.floor(100-_st.marker[1]))
					
					r,g,b = gradient(_st.tbike)
					canvas:attrColor(r,g,b,255)
					text.print(painel.x+painel.bike.x,painel.y+painel.bike.y,_st.tbike)
					
					r,g,b = gradient(100-_st.marker[2])
					canvas:attrColor(r,g,b,255)
					text.print(painel.x+painel.accident.x,painel.y+painel.accident.y,math.floor(100-_st.marker[2]))
				else
					text.print(painel.x+painel.tl.x,painel.y+painel.traffic.y,'Informações não disponíveis. Necessário implantação de um centro de informações.')
				end
				
				_improve = improve[player.hv].street[cursor.sel.i]
				yi = painel.y+painel.stamp.y1
				
				canvas:attrColor(239,216,136,255)
				text.print(painel.x+painel.tl.x,painel.y+painel.busln.yt,'Linhas de ônibus')

				n = 1
				if improve[player.hv].stbus[cursor.sel.i] then
					for lnbus,_lnbus in pairs(improve[player.hv].stbus[cursor.sel.i]) do
						x,y = painel.busln.x1,painel.busln.y1
						if n==3 or n==4 then
							x = painel.busln.x2
						end
						if n==2 or n==4 then
							y = painel.busln.y2
						end
						text.print(painel.x+x,painel.y+y,'LINHA '.._lnbus)
						n = n + 1
					end
				end
			end
		else
			canvas:compose(painel.x,painel.y,painelbase2)
			
			local _bd = build.i[cursor.sel.i]
			
			if _bd then	
				canvas:attrColor(239,216,136,255)
				text.set(painel.tl.w,16,17,'c')
				text.print(painel.x+painel.tl.x,painel.y+painel.tl.y-10,build.name[_bd.t])
				text.set(painel.tl.w,16,17)
				text.print(painel.x+painel.tl.x,painel.y+painel.traffic.y,'Circulação:')
				text.print(painel.x+painel.tl.x,painel.y+painel.auto.y,'Acessibilidade:')

				if not _bd.disable then
					canvas:attrColor(227,227,227,255)
					if _bd.jam then
						jam = 'ALTA'
					else
						jam = 'BAIXA'
					end
					text.print(painel.x+painel.traffic.x2,painel.y+painel.traffic.y,jam)
					
					r,g,b = gradient(100-level[player.hv].build[cursor.sel.i].marker)
					canvas:attrColor(r,g,b,255)
					text.print(painel.x+painel.access.x,painel.y+painel.access.y,100-math.floor(level[player.hv].build[cursor.sel.i].marker))
				end

				_improve = improve[player.hv].build[cursor.sel.i]
				yi = painel.y+painel.stamp.y2
			end
		end
		
		if _improve then
			x = painel.x+painel.stamp.x
			y = yi
			n = 1
			for improve,v in pairs(_improve) do
				if not (improve==6 and _improve[7] or improve==10 and _improve[11]) then
					canvas:compose(x,y,listimg.stamp[improve])
					if n==5 then
						x = painel.x+painel.stamp.x
						y = yi + painel.stamp.yp
					else
						x = x + painel.stamp.xp
					end
				end
			end
		end
	end
end

painel.show = function(i)
	local h
	
	if cursor.sel.t<3 and cursor.sel.i==i and not cursor.active and not painel.on then
		painel.x = cursor.x<610 and cursor.x+30 or cursor.x-painel.w+30
		h = cursor.sel.t==1 and painel.h or painel.h2
		painel.y = cursor.y-35+h>720 and 720-h or cursor.y-35
		
		painel:add()
		painel.on = true
	end
end


-- MENU -----------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------

menu = {x=290,y=92,w=347,h=536,hp=460,yt=29,yb=482,i=0,img={},lb={x=76,y=15},btok={x=538,y=550},btback={x=582,y=550},scr={x=303,y=113,yi=113,dy=444},active=false}


list={x=314,y=112,yai=112,ya=112,w=310,h=472,sel=1,xi=10,yi=45,yp=113,tl={x=152,y=13,w=150},tx={x=160,w=134},icon={x=40,y=16},cost={x1=162,xt=198,y1=44,y2=73,yt1=50,yt2=77},notif={x=7,xtx=27,y=70,w=255,h=35},img={},i={}}


list.i[2] = {}
list.i[2][1] = {tl='Coletar Mel'}
list.i[2][2] = {tl='Rua do Pólen'}
list.i[2][3] = {tl='Jogo das Operárias'}

list.i[3] = {}
list.i[3][1] = {tl='Bem vindo a Vila Favo',tx='Está é Vila Favo, uma simpática cidade construída no interior de uma colméia.'}
list.i[3][2] = {tl='Engarrafamento na Rua do Pólen',tx='A vila foi construída em um lugar distante da entrada da colmeia, para garantir a segurança das moradias, e, portanto, bastante longe da fazenda que fica na entrada. A Rua do Pólen liga a fazenda à vila. Com a dificuldade do caminho, a grande maioria das abelhas demora muito no deslocamento e poucos recursos chegam até a vila. Muitas abelhas estão usando seus veículos, mas logo a estreita rua ficou lotada e o deslocamento de veículos muito lento. Contudo, somente com os veículos é possível trazer recursos suficientes para a vila.'}
list.i[3][3] = {tl='Vila Favo ganha uma fábrica',tx=''}
list.i[3][4] = {tl='Centro de Informações de Trânsito',tx=''}
list.i[3][5] = {tl='Mercado inaugurado em Vila Favo',tx=''}
list.i[3][6] = {tl='Acidentes em Vila Favo aumentam',tx=''}
list.i[3][7] = {tl='Vila Favo tem seu primeiro Shopping',tx=''}
list.i[3][8] = {tl='Sobre a faixa exclusiva para ônibus',tx=''}

list.i[3][9] = {tl='Vila Favo tem seu primeiro Shopping',tx=''}
list.i[3][10] = {tl='Sobre a faixa exclusiva para ônibus',tx=''}
list.i[3][11] = {tl='Bem vindo a Vila Favo',tx='Está é Vila Favo, uma simpática cidade construída no interior de uma colméia.'}
list.i[3][12] = {tl='Engarrafamento na Rua do Pólen',tx='A vila foi construída em um lugar distante da entrada da colmeia, para garantir a segurança das moradias, e, portanto, bastante longe da fazenda que fica na entrada. A Rua do Pólen liga a fazenda à vila. Com a dificuldade do caminho, a grande maioria das abelhas demora muito no deslocamento e poucos recursos chegam até a vila. Muitas abelhas estão usando seus veículos, mas logo a estreita rua ficou lotada e o deslocamento de veículos muito lento. Contudo, somente com os veículos é possível trazer recursos suficientes para a vila.'}
list.i[3][13] = {tl='Vila Favo ganha uma fábrica',tx=''}
list.i[3][14] = {tl='Centro de Informações de Trânsito',tx=''}
list.i[3][15] = {tl='Mercado inaugurado em Vila Favo',tx=''}
list.i[3][16] = {tl='Acidentes em Vila Favo aumentam',tx=''}
--list.i[3][] = {tl='',tx=''}

descr = {x=645,y=104,w=199,h=490,bd={y=10,h=469},ft={y=479},bg={x=2,y=10},tl={x=18,y=13,w=110},stamp={x=142},tx={x=20,y=64,w=150,h=16},btok={x=738,y=550},btback={x=782,y=550},img={}}

notif = {x=348,y=147,w=586,h=427,bd={y=59,h=291},ft={y=350},tx={x=20,y=90,w=546}}

menu.create = function()
	menubase = canvas:new(menu.w,menu.h)

	menubase:compose(0,0,menuimg.item.hd)
	menubase:compose(0,menu.yb,menuimg.item.ft)

	for y=menu.yt,menu.yt+menu.hp do
		menubase:compose(0,y,menuimg.item.bd)
	end

	menubase:flush()
end

menu.draw = function()
	local y
	
	if listbase then
		canvas:attrClip(list.x,list.y,list.w,list.h)
		canvas:compose(list.x,list.ya,listbase)	

		canvas:attrClip(menu.x,menu.y,menu.w,menu.h)
		canvas:compose(menu.x,menu.y,menubase)	
		canvas:compose(menu.x+menu.lb.x,menu.y+menu.lb.y,menuimg.lb[menu.i])

		if menu.i<3 then
			y = list.ya + (list.sel-1)*list.yp + list.yi
			canvas:compose(list.x+list.xi,y,listimg.hr)

			if menu.i==1 then
				canvas:compose(menu.scr.x,menu.scr.y,menuimg.item.scr)	
				
				canvas:attrClip(descr.x,descr.y,descr.w,descr.h)
				canvas:compose(descr.x,descr.y,descrbase)

				canvas:attrClip(descr.x,descr.y,descr.w,descr.h)
				canvas:attrColor(239,216,136,255)
				text.set(descr.tl.w,14,16,'c')
				text.print(descr.x+descr.tl.x,descr.y+descr.tl.y,list.i[1][list.sel].tl)
				text.set(descr.tx.w,14,16)
				text.print(descr.x+descr.tx.x,descr.y+descr.tx.y,list.i[1][list.sel].tx)
				canvas:compose(descr.x+descr.stamp.x,descr.y+descr.tl.y,listimg.stamp[list.sel])
				canvas:compose(descr.btok.x,descr.btok.y,menuimg.item.btok)
				canvas:compose(descr.btback.x,descr.btback.y,menuimg.item.btback)
			else
				canvas:compose(menu.btok.x,menu.btok.y,menuimg.item.btok)
				canvas:compose(menu.btback.x,menu.btback.y,menuimg.item.btback)
			end
		else
			y = list.ya + (list.sel-1)*list.notif.h + list.notif.y
			canvas:compose(list.x+list.notif.x,y,listimg.it.dothr)
			canvas:compose(menu.scr.x,menu.scr.y,menuimg.item.scr)
			canvas:compose(menu.btok.x,menu.btok.y,menuimg.item.btok)
			canvas:compose(menu.btback.x,menu.btback.y,menuimg.item.btback)
		end
	end
end

menu.start = function()
	imsg.msg = ''
	imsg:remove()

	menu.active = true
	menu.i = buttons.sel
	
	list.create()
	notif.create()
	
	buttons.sel = 0
	
	menu.draw()
	menu.setKeys()
end

menu.close = function()
	listbase = nil

	menu.active = false
	buttons.sel = menu.i
	cursor.start()
	canvas:attrClip(menu.x,menu.y,menu.w+descr.w+8,menu.h)
	bg()
end

menu.select = function()
	if menu.i==1 then
		_item = itens[list.sel]
		
		if _item.unlock>0 then
			if player.lv<_item.lv then
				msg('Você não atingiu o nível necessário para desbloquear esse investimento.',75,true)
			elseif player.coin<_item.unlock then
				msg('Você não possui o valor em moedas necessário para desbloquear esse investimento.',75,true)
			else
				y = list.yi + (list.sel-1) * list.yp
				listbase:compose(list.xi,y,listimg.it.bg)
				listbase:compose(list.icon.x,y+list.icon.y,listimg.itens[list.sel])
				text.set(list.tl.w,14,16,'c',listbase)
				text.print(list.tl.x,y+list.tl.y,_item.tl)
				listbase:compose(list.cost.x1,y+list.cost.y1,listimg.cost[1])
				listbase:attrColor(239,216,136,255)
				listbase:drawText(list.cost.xt,y+list.cost.yt1,_item.pr)

				menu.draw()
				
				player.cash('c',_item.unlock*-1)
				itens[list.sel].unlock = 0
			end
		else
			if player.honey<_item.pr then
				msg('Você não possui fundos suficientes para esse investimento.',75,true)
			else
				player.shop(list.sel)
			end
		end
	elseif menu.i==2 then
		game.start(list.sel)
	elseif menu.i==3 then
		onKey('CURSOR_DOWN',nil)
		onKey('CURSOR_UP',nil)
		onKey('CURSOR_LEFT',function()
			notif.draw(true)
			notif.draw(true)
			
			menu.draw()
			menu.setKeys()
		end)
		notif.draw()
	end
end

menu.setKeys = function()
	onKey('ENTER',menu.select)
	onKey('CURSOR_DOWN',function()
		list.browse(1)
	end)
	onKey('CURSOR_UP',function()
		list.browse(-1)
	end)
	onKey('CURSOR_LEFT',function()
		menu.close()
		place.resume()
	end)
	onKey('CURSOR_RIGHT',nil)
end

list.browse = function(n)
	if list.sel+n>=1 and list.sel+n<=#list.i[menu.i] then
		list.sel = list.sel+n
		if list.scroll>0 then
			list.ya = list.ya - n * 1/(#list.i[menu.i]-1) * list.scroll
			menu.scr.y = menu.scr.y + n * 1/(#list.i[menu.i]-1) * menu.scr.dy
		end
		menu.draw()
	end
end

list.create = function()
	local x,y,h,tx,m

	list.sel = 1
	list.ya = list.yai
	
	if menu.i<3 then
		list.size = #list.i[menu.i]*list.yp+list.yi
		list.scroll = list.size - list.h
		
		local _list = list.i[menu.i]
		
		h = list.size<list.h and list.h or list.size	

		listbase = canvas:new(list.w,h)
		listbase:attrColor(77,96,103,255)

		if menu.i==1 then
			listbase:drawRect('fill',0,0,list.w,list.size)
			m = 'itens'
		else
			listbase:drawRect('fill',0,0,list.w,h)
			m = 'mini'
		end
		
		listbase:attrColor(239,216,136,255)
		
		y = list.yi
		for item,_item in pairs(_list) do
			listbase:compose(list.xi,y,listimg.it.bg)

			listbase:compose(list.icon.x,y+list.icon.y,listimg[m][item])
			text.set(list.tl.w,14,16,'c',listbase)
			text.print(list.tl.x,y+list.tl.y,_item.tl)
			
			if menu.i==1 then
				if _item.unlock>0 then
					listbase:compose(list.xi,y,listimg.it.lock)

					listbase:attrColor(239,216,136,255)
					listbase:drawText(list.cost.x1+5,y+list.cost.yt1,'Nível '.._item.lv)


					listbase:compose(list.cost.x1,y+list.cost.y2,listimg.cost[2])
					listbase:attrColor(239,216,136,255)
					listbase:drawText(list.cost.xt,y+list.cost.yt2,_item.unlock)
				else
					listbase:compose(list.cost.x1,y+list.cost.y1,listimg.cost[1])
					listbase:attrColor(239,216,136,255)
					listbase:drawText(list.cost.xt,y+list.cost.yt1,_item.pr)
				end
			elseif menu.i==2 then
				tx = 'Ganha '..game.earn[item]..' moedas.'
				text.set(list.tx.w,14,16,nil,listbase)
				text.print(list.tx.x,y+list.cost.yt1,tx)
			end

			y = y + list.yp
		end
		listbase:flush()
		
		if menu.i==1 then
			descrbase = canvas:new(descr.w,descr.h)
			descrbase:compose(0,0,descrimg.hd)
			for y=descr.bd.y,descr.bd.y+descr.bd.h do
				descrbase:compose(0,y,descrimg.bd)
			end
			descrbase:compose(descr.bg.x,descr.bg.y,descrimg.bg)
			descrbase:compose(0,descr.ft.y,descrimg.ft)
			
			descrbase:flush()
		end
	else
		list.size = #list.i[3]*list.notif.h+list.notif.y
		list.scroll = list.size - list.h
		
		h = list.size<list.h and list.h or list.size	

		listbase = canvas:new(list.w,h)
		listbase:attrColor(77,96,103,255)
		
		listbase:drawRect('fill',0,0,list.w,h)
		
		y = list.notif.y
		for n=#list.i[3],1,-1 do
			listbase:compose(list.notif.x,y,listimg.it.dot)
			
			listbase:attrColor(239,216,136,255)
			text.set(list.notif.w,14,16,nil,listbase)
			text.print(list.notif.xtx,y+2,list.i[3][n].tl)
			y = y + list.notif.h

		end
	end
end

notif.create = function()
	notifbase = canvas:new(notif.w,notif.h)
	notifbase:compose(0,0,menuimg.box.notif)
	notifbase:compose(0,notif.ft.y,boximg.ft)
	
	for y=notif.bd.y,notif.bd.y+notif.bd.h do
		notifbase:compose(0,y,boximg.bd)
	end
	notifbase:compose(522,notif.ft.y-33,boximg.btback)
	notif.show = false
end

notif.draw = function(clear)
	canvas:attrClip(notif.x,notif.y,notif.w,notif.h)
	if clear then
		bg()
	else
		canvas:compose(notif.x,notif.y,notifbase)
		canvas:attrColor(239,216,136,255)
		text.set(notif.tx.w,16,20)
		text.print(notif.x+notif.tx.x,notif.y+notif.tx.y,list.i[3][#list.i[3]-list.sel+1].tx)
	end
end

box = {x=348,y=147,w=586,h=427,bd={y=21,h=329},ft={y=350},tx={x=35,y=110,w=516},tl={x=20,y=62},nr={x=20,y=130,yp=64},line={x=90,xl=27,xp=100,yl=-16,yt=17,w=100},bt={x=870,y=464},i={}}
boximg = {hd=canvas:new('img/boxhd.png'),bd=canvas:new('img/boxbd.png'),ft=canvas:new('img/boxft.png'),btback=canvas:new('img/btback1.png'),btok=canvas:new('img/btok1.png')}

box.create = function()
	boxbase = canvas:new(box.w,box.h)
	boxbase:compose(0,0,boximg.hd)
	boxbase:compose(0,box.ft.y,boximg.ft)
	for y=box.bd.y,box.bd.y+box.bd.h do
		boxbase:compose(0,y,boximg.bd)
	end
end

box.draw = function(clear)
	local x

	canvas:attrClip(box.x,box.y,box.w,box.h)
	if clear then
		bg()
	else
		canvas:compose(box.x,box.y,boxbase)
		canvas:attrColor(239,216,136,255)
		text.set(box.tx.w,20,18,'c')
		text.print(box.x+box.tl.x,box.y+box.tl.y,box.i[1])
		text.set(box.tx.w,16,20)
		text.print(box.x+box.tx.x,box.y+box.tx.y,box.i[2])
		
		x = box.bt.x
		if box.i[4] then
			canvas:compose(x,box.bt.y,boximg.btback)
			x = x - 48
		end
		if box.i[3] then
			canvas:compose(x,box.bt.y,boximg.btok)
		end
	end
end

boxBus = {tx={x=20,y=72,w=546},nr={x=20,y=108,yp=56},line={x=90,xl=27,xp=100,yl=-16,yt=17,w=100}}

boxBus.draw = function(clear)
	local x,y,nr

	canvas:attrClip(box.x,box.y,box.w,box.h)
	if clear then
		bg()
	else
		canvas:compose(box.x,box.y,boxbase)
		canvas:attrColor(239,216,136,255)
		text.set(box.tx.w,16,18)
		text.print(box.x+boxBus.tx.x,box.y+boxBus.tx.y,'Com as setas do controle, escolha um novo trecho a ser implantado.')
		text.set(box.tx.w,16,18,'c')
		text.print(box.x+boxBus.tx.x,box.y+boxBus.tx.y-38,'LINHAS DE ÔNIBUS')
		canvas:compose(box.bt.x,box.bt.y,boximg.btback)
		canvas:compose(box.bt.x-48,box.bt.y,boximg.btok)
			
		y = box.y+boxBus.nr.y
		
		for lnbus,_lnbus in pairs(level[player.hv].lnbus) do
			text.set(boxBus.tx.w,16,16)
			nr = player.hv..lnbus..'0'
			text.print(box.x+boxBus.nr.x,y,'LINHA '..nr)

			implanted = improve[player.hv].lnbus[lnbus] and improve[player.hv].lnbus[lnbus] or 0

			x = box.x+boxBus.line.x
			for strch,_strch in pairs(_lnbus) do
				if _strch.st then
					if strch>implanted+1 then
						canvas:compose(x+boxBus.line.xl,y+boxBus.line.yl,menuimg.box.lna)
					elseif strch>implanted then
						canvas:compose(x+boxBus.line.xl,y+boxBus.line.yl,menuimg.box.lnb)
					else
						canvas:compose(x+boxBus.line.xl,y+boxBus.line.yl,menuimg.box.lnc)
					end
				end
				text.set(boxBus.line.w,12,13,'c')
				text.print(x,y+boxBus.line.yt,_strch.lc)
				x = x + boxBus.line.xp
			end
			
			if lnbus==boxBus.sel then
				x = box.x+boxBus.line.x + (implanted)*boxBus.line.xp
				canvas:compose(x+boxBus.line.xl,y+boxBus.line.yl,menuimg.box.lnhr)
			end
			y = y + boxBus.nr.yp
		end
	end
end

boxBus.browse = function(sel)
	if sel>0 and sel<=#level[player.hv].lnbus then
		boxBus.sel = sel
		boxBus.draw()
	end
end

boxBus.start = function()
	local sel,ln = 0,1
	local lnbus = level[player.hv].lnbus

	while sel==0 and ln<=#lnbus do
		if not improve[player.hv].lnbus[ln] or improve[player.hv].lnbus[ln] < #lnbus[ln]-1 then
			sel = ln
		end
		ln = ln+1
	end

	if sel==0 then
		menu.close()
		place.resume()
		msg('Todas as linhas foram implantadas nesta região.')
	else
		boxBus.sel = sel
		boxBus.draw()
		onKey('ENTER',function()
			if not improve[player.hv].lnbus[boxBus.sel] then
				improve[player.hv].lnbus[boxBus.sel] = 0
			end

			if improve[player.hv].lnbus[boxBus.sel] < #lnbus[boxBus.sel]-1 then

				improve[player.hv].lnbus[boxBus.sel] = improve[player.hv].lnbus[boxBus.sel]+1
			
				local strch = improve[player.hv].lnbus[boxBus.sel]
				local st = level[player.hv].lnbus[boxBus.sel][strch].st
				
				if not improve[player.hv].stbus[st] then
					improve[player.hv].stbus[st] = {}
				end
				
				player.improve('lnbus',st,boxBus.sel)
				
				menu.close()
			end
		end)
		onKey('CURSOR_DOWN',function()
			boxBus.browse(boxBus.sel+1)
		end)
		onKey('CURSOR_UP',function()
			boxBus.browse(boxBus.sel-1)
		end)
		onKey('CURSOR_LEFT',function()
			menu.close()
			place.resume()
		end)
		onKey('CURSOR_RIGHT',nil)
	end
end

-- MSG ----------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

imsg = obj:new('msg',6,{x=347,y=220,w=586,h=153,tm=75,img={},msg='',tx={x=40,y=40,w=506}})
imsgimg=canvas:new('img/msg.png')

imsg.draw = function()
	canvas:attrClip(imsg.x,imsg.y,imsg.w,imsg.h)
	if imsg.msg == '' then
		bg()
	else
		canvas:compose(imsg.x,imsg.y,imsgimg)
		canvas:attrColor(239,216,136,255)
		text.set(imsg.tx.w,16,17,'c')
		text.print(imsg.x+imsg.tx.x,imsg.y+imsg.tx.y,imsg.msg)
	end
end

msg = function(tx,tm,mode)
	imsg.msg = tx
	if not tm then
		tm = imsg.tm
	end
	
	if menu.active then
		imsg.draw()
		wait(tm,function()
			imsg.msg = ''
			imsg.draw()
			menu.draw()
		end)
	else
		imsg:add()
		wait(tm,function()
			imsg.msg = ''
			imsg:remove()
		end)
	end
end


-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

