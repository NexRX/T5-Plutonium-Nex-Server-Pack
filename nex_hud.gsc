#include maps\_hud_util;


getBaseMessurements()
{
	base = spawnStruct();
	base.align = "center";	  	// "center" default
	base.relative = "center"; 	// "center" default
	base.x = 360; 			  	// 330 default
	base.y = 0; 			  	// 0 deafult
	base.width = -65; 		  	// 0 default 
	base.height = -50; 	 	  	// 0 deafult
	base.color = (0.4,0,0); 	// (0.3,0.3,1) default
	base.sort = 1; 			  	// 1 default
	base.optionHeight = 22;   	// 20 or 22 default
	base.barHeight = 5; 	  	// 5 default
	base.footerbarHeight = 25;	// 5 default
	base.headingfontScale = 1.5;// 2 default
	base.textfontScale = 1;   	// 1.5 default
	base.titleoffset = -100;  	// -100 default
	base.footerOffset = 92;   	// 100 default
	base.backgroundOffset = -20;// 0 default

	return base;
}

preUIInit()
{
	level.menu["options"] = [];
}

startingPlayersHUD()
{
	base = getBaseMessurements();

	if(self.name == "level.hostname")
		self.menu["verification"] = "host";
	else
		self.menu["verification"] = "unverified";
	self.menu["open"] = false;
	self.menu["curMenu"] = 0;
	self.menu["curOpt"] = 0;
	self.menu["shader"] = self createRectangle(base.align,base.relative,base.x,base.y + base.backgroundOffset,base.width + 200, base.height + 300,(0,0,0),0,0); 
	self.menu["scroller"] = createRectangle("center","center",base.x,base.y - 85,base.width + 200,base.optionHeight,base.color,1,0);
	self.menu["titlebar"] = self createRectangle("center","center",base.x,base.y - 100,base.width + 200,base.barHeight,base.color,1,0);
	self.menu["footer"] = self createRectangle("center","center",base.x,base.y + base.footerOffset,base.width + 200,base.footerbarHeight,base.color,1,0);

	self.god = false;

	//self thread monitorButtons();
	self buildOptions();
}

test()
{
	self iPrintln("Testing");
}

doGod()
{
	if(self.god == false)
	{
		self enableInvulnerability();
		self iPrintln("Godmode: ^2Enabled");
		self.god = true;
	}
	else if(self.god == true)
	{
		self disableInvulnerability();
		self iPrintln("Godmode: ^1Disabled");
		self.god = false;
	}
}

newMenu(menu)
{
	for(i=0;i<self.menu["option"][self.menu["curMenu"]].size;i++)
		self.menu["text"][i] setText("");
	self.menu["curMenu"] = menu;
	self.menu["curOpt"] = 0;
	self.menu["scroller"] moveOverTime(0.3);
	self.menu["scroller"].y = self.menu["text"][self.menu["curOpt"]].y;
	for(i=0;i<self.menu["option"][self.menu["curMenu"]].size;i++)
		self.menu["text"][i] setText(self.menu["option"][self.menu["curMenu"]][i]);
}

menuOptionStruct(menuIndex, listIndex, name, func, arg)
{
	menuOption = spawnStruct();
	menuOption.menuIndex = menuIndex;
	menuOption.listIndex = listIndex;
	menuOption.name = name;
	menuOption.func = func;
	menuOption.arg = arg;

	return menuOption;
}

buildOptions()
{
	for (i = 0; i < level.menu["options"].size; i++)
	{
		self addMenu(level.menu["options"][i].menuIndex, level.menu["options"][i].listIndex, level.menu["options"][i].name, level.menu["options"][i].func, level.menu["options"][i].arg);
	}
	// Old way
	//self addMenu(0,1,"Test Option", ::test);
	//self addMenu(0,2,"Test Option", ::test);
	//self addMenu(0,3,"Test Option", ::test);
	//self addMenu(0,4,"Test Option", ::test);
	//self addMenu(0,5,"Test Option", ::test);
	//self addMenu(0,6,"Test Option", ::test);
	//self addMenu(0,7,"Test Option", ::test);

	//self addMenu(1,0,"God Mode", ::doGod);
	//self addMenu(1,1,"Sub Option", ::test);
	//self addMenu(1,2,"Sub Option", ::test);
	//self addMenu(1,3,"Sub Option", ::test);
	//self addMenu(1,4,"Sub Option", ::test);
}

addMenu(menu, num, text, func, arg)
{
	self.menu["option"][menu][num] = text;
	self.menu["func"][menu][num] = func;
	self.menu["arg"][menu][num] = arg;
}

// Menu Controls
menuOpen()
{
    base = getBaseMessurements();
	if(self.menu["open"] == false && self.menu["verification"] != "unverified")
	{
		self iPrintln("Menu: ^2Open");
		self.menu["shader"] fadeOverTime(0.5);
		self.menu["shader"].alpha = 0.6;
		self.menu["scroller"] fadeOverTime(0.5);
		self.menu["scroller"].alpha = 1;
		self.menu["footer"] fadeOverTime(0.5);
		self.menu["footer"].alpha = 1;
		self.menu["titlebar"] fadeOverTime(0.5);
		self.menu["titlebar"].alpha = 1;
		self.menu["title"] = self TextSet(base.align, base.relative, base.x, base.y - 125, base.sort, base.headingfontScale, "Server Menu");
		self.menu["tips1"] = self TextSet(base.align, base.relative, base.x, base.y + 85, base.sort, base.textfontScale, "Next: ^37^7 or ^3V^7      |      Select: ^3F^7");
		self.menu["tips2"] = self TextSet(base.align, base.relative, base.x, base.y + 100, base.sort, base.textfontScale, "Close/Back: ^3Shift + F^7");
		for(i=0;i<self.menu["option"][self.menu["curMenu"]].size;i++)
        {
			self.menu["text"][i] = self TextSet(base.align, base.relative, base.x, base.y - 85+(i*base.optionHeight), base.sort, base.textfontScale, self.menu["option"][self.menu["curMenu"]][i]);
        }
		self.menu["open"] = true;
	}
}

menuClose()
{
    if(self.menu["curMenu"] != 0)
    {
		self newMenu(0);
    }
	else if (self.menu["open"] == true)
	{
		for(i=0;i<self.menu["text"].size;i++)
        {
			self.menu["text"][i] destroy();
        }
		self.menu["title"] destroy();
		self.menu["tips1"] destroy();
		self.menu["tips2"] destroy();
		self.menu["shader"] fadeOverTime(0.5);
		self.menu["shader"].alpha = 0;
		self.menu["scroller"] fadeOverTime(0.5);
		self.menu["scroller"].alpha = 0;
		self.menu["footer"] fadeOverTime(0.5);
		self.menu["footer"].alpha = 0;
		self.menu["titlebar"] fadeOverTime(0.5);
		self.menu["titlebar"].alpha = 0;
		self.menu["open"] = false;
	}
}

menuNavigate(reverse)
{
	self notify("menuNavigation");

    if(self.menu["open"] == true)
    {
		if (!isDefined(reverse) || reverse == false) reverse = -1;
	    self.menu["curOpt"] -= reverse; //increment selected

	    if(self.menu["curOpt"] > self.menu["option"][self.menu["curMenu"]].size-1) 
        { 
            self.menu["curOpt"] = 0; 
        }

	   	if(self.menu["curOpt"] < 0) 
        { 
            self.menu["curOpt"] = self.menu["option"][self.menu["curMenu"]].size-1; 
        }

        self endon("menuNavigation");

	   	self.menu["scroller"] moveOverTime(0.3);
	   	self.menu["scroller"].y = self.menu["text"][self.menu["curOpt"]].y;
    }
}

menuSelect()
{
    if(self.menu["open"] == true && isDefined(self.menu["arg"][self.menu["curMenu"]][self.menu["curOpt"]]))
    {
		self [[self.menu["func"][self.menu["curMenu"]][self.menu["curOpt"]]]](self.menu["arg"][self.menu["curMenu"]][self.menu["curOpt"]]);
    } else if (self.menu["open"] == true)
	{
	self [[self.menu["func"][self.menu["curMenu"]][self.menu["curOpt"]]]]();
	}
}

menuOpenElseNavigate(reverse)
{
	if (self.menu["open"] == false)
	{
		menuOpen();
	} 
	else
	{
		menuNavigate(reverse);
	}
}

menuNavigateIfOpen(reverse)
{
	if (self.menu["open"] == true)
	{
		menuNavigate(reverse);
	}
}

monitorButtons()
{
	for(;;)
	{
		if(self adsbuttonpressed() && self meleebuttonpressed())
		{
			self menuOpen();
		}
		if(self meleebuttonpressed() && self.menu["open"] == true)
		{
			self menuClose();
		}
		if(self adsButtonPressed() || self attackButtonPressed())
        {
            self menuNavigate();
        }
		if(self usebuttonpressed() && self.menu["open"] == true)
		{
			self menuSelect();
		}
		wait 0.1;
	}
}

TextSet(Align_X, Align_Y, X, Y, Alpha, TextSize, SetText) {
    Text = self createfontstring("default", TextSize, self);
    Text setpoint(Align_X, Align_Y, X, Y);
    Text settext(SetText); Text.alpha = Alpha;
    return Text;
}

createRectangle(align,relative,x,y,width,height,color,sort,alpha) 
{
	barElemBG = newClientHudElem( self );
	barElemBG.elemType = "bar";
	if ( !level.splitScreen )
	{
		barElemBG.x = -2;
		barElemBG.y = -2;
	}
	barElemBG.width = width;
	barElemBG.height = height;
	barElemBG.align = align;
	barElemBG.relative = relative;
	barElemBG.xOffset = 0;
	barElemBG.yOffset = 0;
	barElemBG.children = [];
	barElemBG.sort = sort;
	barElemBG.color = color;
	barElemBG.alpha = alpha;
	barElemBG setParent( level.uiParent );
	barElemBG setShader( "white", width , height );
	barElemBG.hidden = false;
	barElemBG setPoint(align,relative,x,y);
	return barElemBG;
}