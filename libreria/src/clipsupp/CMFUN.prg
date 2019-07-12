// ******************************************************************
// ********** FUNZIONI CLIPMORE ALASKA 1.3 **************************
// ********** VERS. 12.02.2000 **************************************
// ******************************************************************
function cm2Str(xValue)
	local n
	local cRet
	local cType := valType(xValue)

	do case

	case (cType == 'C') .or. (cType == 'M')
		cRet := ''

			//	Handle fact that " might be part of string
		while ((n := at('"', xValue)) != 0)
			cRet += '"' + substr(xValue, 1, n-1) + '"'
			cRet += '+["]+'
			xValue := substr(xValue, n+1)
		end
		cRet += '"' + xValue + '"'

	case (cType == 'D')
		cRet := "ctod('" + dtoc(xValue) + "')"

	case (cType == 'L')
		cRet := iif(xValue, ".T.", ".F.")

	case (cType == 'N')
		cRet := str(xValue, 31, 10)

			//	Trim off trailing 0's
		for n := 31 to 1 step -1
			if (substr(cRet, n, 1) != '0')
				exit
			endif
		next n

			//	Clear off decimal if not needed
		if (substr(cRet, n, 1) == '.')
			--n
		endif

			//	Get the result after the above cleanup
		cRet := alltrim(substr(cRet, 1, n))

	endcase
return cRet
// ------
// ***********************************************************
function cmClrFilter()
	dbClearFilter()
return nil
// ------
// ***********************************************************
function cmFilter(cFilter)
	if empty(cFilter)
		dbClearFilter()
	else
		dbSetFilter(& ("{||" + cFilter + "}"), cFilter)
	endif
return nil
// ------
// ***********************************************************
function cmKeyGoto(nCount)
	if (valType(nCount) == 'N')
		go top
		if (nCount > 1)
			skip (nCount - 1)
		endif
	endif
return nil
// ------
// ***********************************************************
function cmKeySkip(nCount)
	if (valType(nCount) == 'N')
		skip nCount
	endif
return nil
// ------
// ***********************************************************
function cmKeyNo(xTag, cBag)
return ordKeyNo(xTag, cBag)
// ------
// ***********************************************************
function cmReFilter(cCond)
	local cNewCond, bNewCond
	//local rlNew

	if empty(dbFilter())
		return cmFilter(cCond)
	endif

	if (valType(cCond) == 'C') .and. (!empty(cCond))
		cNewCond = alltrim(dbfilter()) + " .and. " + alltrim(cCond)
		bNewCond = &("{||" + cNewCond + "}")
		dbSetFilter(bNewCond, cNewCond)
	endif
return nil
// ------
// ***********************************************************
function cmSmartFilter()
return .t.
// ------
// ***********************************************************
function cmVersion(nVer)
	static cVer := "3.00.07 (ClipMore/5.3)"
	static anOfs := { 4, 7, 22 }

	if (valType(nVer) != 'N')
		nVer := 0
	endif
	if (nVer < 0)
		nVer = 0
	endif
	if (nVer > 2)
		nVer = 2
	endif
return left(cVer, anOfs[nVer+1])
// ------
// ****************** FINE MODULO CMFUN.PRG *************************
