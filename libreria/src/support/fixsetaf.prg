FUNCTION FixSetAppFocus( o )
RETURN IIF(EMPTY(o), SetAppFocus(), SetAppFocus(o))
