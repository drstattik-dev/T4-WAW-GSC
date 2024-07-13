#define OVERFLOW_MAX_STRINGS 30

createElem(horz, vert, alX, alY, x, y, color, isLevel)
{
    if(isDefined(isLevel))
        textElem = NewHudElem();
    else
        textElem = NewClientHudElem(self);
    textElem.horzAlign = horz;
    textElem.vertAlign = vert;
    textElem.alignX = alX;
    textElem.alignY = alY;
    textElem.y = y;
    textElem.x = x;
    textElem.foreground = 1;
	textElem.color = color;

    return textElem;
}

initOverflowFix()
{
	level.wawr_text_hud_marker = newHudElem();
	level.wawr_text_hud_marker setText( "OverflowFix" );
	level.wawr_text_hud_marker.alpha = 0;

	for(;;)
	{
		level waittill("end_game");
		clear_hud_text();
		restore_hud_text();
	}
}

restore_hud_text()
{
	for ( i = 0; i < level.wawr_text_hud_elems.size; i++ )
	{
		level.wawr_text_hud_elems[ i ] setText( level.wawr_text_hud_elems[ i ].current_text );
		if ( isDefined( level.wawr_text_hud_elems[ i ].current_value ) )
		{
			level.wawr_text_hud_elems[ i ] setValue( level.wawr_text_hud_elems[ i ].current_value );
		}
	}
}

clear_hud_text()
{
	level.wawr_text_hud_marker clearAllTextAfterHudElem();
	for ( i = 0; i < level.wawr_text_hud_elems.size; i++ )
	{
		level.wawr_text_hud_elems[ i ] setText( "" );
	}
	level.overflow_fix_current_string_count = 0;
}

find_free_index_for_hud_elem()
{
	for ( i = 0; i < level.wawr_text_hud_elems.size; i++ )
	{
		if ( !isDefined( level.wawr_text_hud_elems[ i ] ) )
		{
			return i;
		}
	}
	return level.wawr_text_hud_elems.size;
}

register_hud_overflow_fix_for_hudelem( hudelem, current_text, current_value )
{
	if ( !isDefined( level.wawr_text_hud_elems ) )
	{
		level.wawr_text_hud_elems = [];
	}
	if ( !isDefined( hudelem.overflow_fix_index ) )
	{
		free_index = find_free_index_for_hud_elem();
		level.wawr_text_hud_elems[ free_index ] = hudelem;
		hudelem.overflow_fix_index = free_index;
	}
	hudelem.current_text = current_text;
	if ( isDefined( current_value ) )
	{
		hudelem.current_value = current_value;
	}
}

unregister_hud_overflow_fix_for_hudelem( hudelem )
{
	index = hudelem.overflow_fix_index;
	level.wawr_text_hud_elems[ index ] destroy();
	//clear_hud_text();
	//restore_hud_text();
}

set_safe_text( text, value )
{
	if ( !isDefined( level.overflow_fix_current_string_count ) )
	{
		level.overflow_fix_current_string_count = 0;
	}
	if ( level.overflow_fix_current_string_count > OVERFLOW_MAX_STRINGS )
	{
        //iPrintLn( "OverflowFix: Too many strings, clearing!" );
		clear_hud_text();
		restore_hud_text();
	}
	if ( isDefined( value ) )
	{
		self.label = text;
		self setValue( value );
	}else{
		self.label = "";
		self.current_value = undefined;
		self setText( text );
	}
	register_hud_overflow_fix_for_hudelem( self, text, value );
	level.overflow_fix_current_string_count++;
}