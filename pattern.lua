#!/usr/bin/env lua
math.randomseed(os.time())

--functions
local function reverseTable(toRev) -- reverses a table and returns
	local newTbl = {}
	for i=#toRev, 1, -1 do
		newTbl[#newTbl+1] = toRev[i]
	end
	return newTbl
end

local function preserveInds(tbl, excl) -- ensure random value wont overright anything
	local rand = math.random(excl,#tbl)
	while tbl[rand] ~=0 do
		rand = math.random(excl,#tbl)
	end
	return rand
end

local function KorP(args) -- insert knit or purl stitches with the right amount of them
	local tbl = args.tbl
	local side = args.kp
	local amnt = args.amnt
	if side then
		table.insert(tbl, #tbl+1, "k" .. tostring(amnt))
	else
		table.insert(tbl, #tbl+1, "p" .. tostring(amnt))
	end
	return tbl
end

local function pickSt(amnt, side)
	local sts
	if side then
		sts = {'YO', 'dYO', 'k2tog', 'ssk', 'sl2tog'}
	else
		sts = {'rYO', 'DrYO', 'p2tog', 'p2togtbl', 'p3tog', "p2sso"}
	end
	if amnt == 1 then
		return sts[1]
	elseif amnt == 2 then
		return sts[2]
	elseif amnt == -1 then
		if side then
			return sts[math.random(3,4)]
		else
			return sts[math.random(3,4)]
		end
	elseif amnt == -2 then
		if side then
			return sts[#sts]
		else
			return sts[math.random(5,#sts)]
		end
	end
end

local function makeRow(left, side)
	local right = {}
	local sameCount = 0
	while #left>0 do
		if left[#left] == 0 then
			while left[#left] == 0 do
				sameCount = sameCount + 1
				table.remove(left, #left)
			end
			right = KorP{tbl=right, kp=side, amnt=sameCount}
			sameCount = 0
		else
			table.insert(right, #right+1, pickSt(left[#left], side))
			table.remove(left, #left)
		end
	end
	return right
end

local function populate(tbl, amnt)
	local randRange, randInd;
	for _=1, amnt do
		randInd = preserveInds(tbl, 14)
		randRange = math.random(-2,-1)
		tbl[randInd] = randRange
		for _=1, math.abs(randRange) do
			table.remove(tbl,1)
		end
	end
	for i=1, #tbl do
		if tbl[i] ~=0 and tbl[i] < 0 then
			randInd = preserveInds(tbl, 1)
			table.insert(tbl, math.abs(tbl[i]))

		end
	end
	table.insert(tbl, 1, 0)
	table.insert(tbl, #tbl+1, 0)
	return tbl
end

local function writePattern(pattern)
	local preamble = ".ds CH\n.vs 15\n.po 0.25i\n\n"
	local line;
	local file = io.open("pattern.ms", 'w')
	file:write(preamble)
	file:write('.DS C\n.ps 15\n                                This is a pattern for the Random Lace Scarf found on\n.pdfhref W -D \"https://knitting-and-so-on.blogspot.com/2015/05/random-lace-scarf.html\"  \"                            Sybl Ra\'s blog.\"\n                            Enjoy the adventure!\n.DE\n.ps 15\n.vs 15\n.ll 7.50i\n\n\n')
	for l, row in pairs(pattern) do
		line = table.concat(row, ", ")
		file:write( '.B \"' .. l ..'. \" \"' .. line ..'\"' .. "\n\n\n" )
	end
	file:close()
	
	os.execute("groff -ms -Tpdf pattern.ms > pattern.pdf")
	--[[ if you don't have groff, uncomment below for a tex implemenation
	local file = io.open("pattern.tex", "w")
	local preamble = "\\documentclass{article}\n\\usepackage{blindtext}\n\\usepackage{hyperref}\n\\hypersetup{\ncolorlinks=true,\nlinkcolor=blue,\nurlcolor=cyan}\n\\usepackage[margin=0.50in]{geometry}\n\\usepackage{enumitem}\n\\begin{document}\n\\begin{LARGE}\n\\begin{center}\nThis is a pattern for \\href{https://knitting-and-so-on.blogspot.com/2015/05/random-lace-scarf.html}{Sybl Ra's blog}\n\nEnjoy the adventure!\n\\end{center}\n\n\\begin{enumerate}[label=\\textbf{\\arabic*}, itemsep=15pt]\n\n\n"
	local line;
	file:write(preamble)
	for l, row in pairs(pattern) do
		line = table.concat(row, ", ")
		file:write("\\item " .. line .. "\n\n")
	end
	file:write("\\end{enumerate}\n\\end{LARGE}\n\\end{document}")
	file:close()
	os.execute("pdflatex pattern.tex")
	]]
end

local function shuffle(tbl)
	for i=#tbl-1, 2, -1 do
		local j = math.random(2, i)
		tbl[i], tbl[j] = tbl[j], tbl[i]
	end
	return tbl
end

--main block
local leftN = {}
local pattern = {} --2d table holding all needed rows
print("enter rows per inch: ")
local guage = io.read("n")
local neededSts = guage * 70

for i=1, neededSts do -- generata all rows in the pattern
	for j=1, 48 do -- initialize the table
		leftN[j] = 0
	end
	leftN = populate(leftN, 7)
	local rightN = makeRow(leftN, i % 2 == 0)
	pattern[#pattern+1] = shuffle(reverseTable(rightN)) -- reverse the rightN to get row
end

writePattern(pattern)

