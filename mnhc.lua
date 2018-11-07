local tm = {c=0}
local score = 0

tm.i = 20000
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

gamebg = canvas:new('img/mnhc/bg.jpg')
gamehr = canvas:new('img/mnhc/hr.png')
gamehn = canvas:new('img/mnhc/hn.png')

canvas:attrClip(0,0,1280,720)
canvas:compose(0,0,gamebg)
canvas:compose(46,38,clkimg[9])

hive = obj:new('hive',7,{x=265,y=58,w=731,h=504,xd=100,yd=112,y2=114})

hive.i = {
	{false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false},
	{false,false,false,false,false,false,false}
}

hive.draw = function()
	local r,_r,c,fv,x,y

	canvas:attrClip(hive.x,hive.y,hive.w,hive.h)
	canvas:compose(0,0,gamebg)

	for r,_r in pairs(hive.i) do
		for c,fv in pairs(_r) do
			x = hive.x + (c-1) * hive.xd
			y = c%2==0 and hive.y2 + (r-1) * hive.yd or hive.y + (r-1) * hive.yd
			if fv then
				canvas:compose(x,y,gamehn)
			end
			if sel.r==r and sel.c==c then
				canvas:compose(x,y,gamehr)
			end
		end
	end
end

hive.browse = function(r,c)
	r = sel.r+r
	c = sel.c+c
	
	if r>0 and r<=4 and c>0 and c<=7 then
		if r==1 and c==1 and sel.c==2 then
			sel.r = 2
			sel.c = 1
		elseif r==1 and c==7 and sel.c==6 then
			sel.r = 2
			sel.c = 7
		elseif r==4 and c<3 and sel.c==3 then
			sel.r = 3
			sel.c = 2
		elseif r==4 and c>5 and sel.c==4 then
			sel.r = 3
			sel.c = 6
		elseif not(r==1 and c==1 or r==1 and c==7 or r==4 and c<3 or r==4 and c>5) then
			sel.r = r
			sel.c = c
		end
		
		hive.get()
	end
end

hive.honey = function()
	local r,c
	
	r = math.random(1,4)
	c = math.random(1,7)
	
	if r==1 and c==1 or r==1 and c==7 or r==4 and c<3 or r==4 and c>5 then
		hive.honey()
	else
		hive.i[r][c] = true
		hive.tm = event.timer(math.random(1,12)*100,hive.honey)
	end
end

hive.get = function()
	if hive.i[sel.r][sel.c] then
		hive.i[sel.r][sel.c] = false
		score = score + 1
		result()
	end
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
	hive.tm = nil
	onKey('CURSOR_DOWN',nil)
	onKey('CURSOR_UP',nil)
	onKey('CURSOR_LEFT',nil)
	onKey('CURSOR_RIGHT',nil)

	wait(30,function()
		hive:remove()
		gamebg = nil
		gamehr = nil
		gamehn = nil

		imsg.msg = 'Muito bem! Você conquistou '..game.earn[1]..' em moedas e mais '..score..' em mel'
		imsg.draw()
		event.timer(2500,function()
			game.done()
			player.cash('h',score)
		end)
	end)
end

box.i = {'COLETAR MEL','Use as setas do controle remoto para coletar o mel dos favos. Ganhe '..game.earn[1]..' em moedas e mais a quantidade de mel que conseguir.'}
box.draw()

onKey('ENTER',function()
	onKey('ENTER',nil)
	canvas:compose(0,0,gamebg)

	onKey('CURSOR_UP',function()
		hive.browse(-1,0)
	end)
	onKey('CURSOR_DOWN',function()
		hive.browse(1,0)
	end)
	onKey('CURSOR_LEFT',function()
		hive.browse(0,-1)
	end)
	onKey('CURSOR_RIGHT',function()
		hive.browse(0,1)
	end)
	sel = {r=1,c=2}
	
	hive:add()

	hive.tm = event.timer(100,hive.honey)
	tm.f()
end)