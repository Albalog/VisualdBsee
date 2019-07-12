Xml v3.0
Copyright Phil Ide 2004, All Rights Reserved

My original XML parser had numerous problems, because the code wasn't
able to do some things very well.  It became pretty complex in an
attempt to cope with some of the complexities of XML (the complexities
arise from exceptions to standard format <name [attrib=value]>dat</name>
format).

The second parser resolved most of those issues by using regular
expressions to chop the document.  It was found though, that certain
constructs would defeat the parser.

This parser is different.  It uses well defined and tested techniques
for parsing, and represents a heavily bastardised and rationalised
version of a parser I am working on for a compiler.

It works by using a lexical parser to break the document down into
atomic and sub-atomic units, and a lexical analyser/semantic analyser to
decide how decomposition should proceed.  The back-end of the compiler
has been replaced by an Xbase++ class generator.

Written entirely in pure Xbase++, it shows how properly implemented
parsers can be used to parse a wide variety of files.  In this case,
an XML file can be parsed quickly and efficiently.  Using similar
techniques, you could also parse:

   Rich-Text Format
   MS-Word documents
   HTML
   CSV
   SDF
   SQL (command)

The BNF for the language the parser handles is:

  id      -> [a-zA-Z]+ALPHANUM
  value   -> ANY_PRINTABLE_CHARACTER
  data    -> ANY_PRINTABLE_CHARACTER
  attrib  -> id="value"
  declare -> <?xml [attrib]* ?>
  expr    -> <id [attrib]*>[expr|data]*</id>
           | <id [attrib]* />
           | <!id [attrib]*>
           | declare

I make no apology that the code doesn't follow a more formal
construction - I took an existing parser and hacked it down, then added
sufficient code as and where necessary to interpret the input stream
properly.  If I was starting from scratch, I may well have done a better
job of seperating the lexical analyser from the semantic analyser, or
brought the two together into a single unit in a much neater fashion.

Regardless, the parser appears to work on a wide variety of sample
documents, many of which were selected because they had defeated the
previous incarnations of the XML parser.  It is blazingly fast,
despite the fact that it reads the input stream one byte at a time, which
is a testament to Xbase++'s ability more than the code.  I have
attempted to optimise the code where I could, using my high-resolution
timer to nip-out millionths of a second where appropriate (since the
code runs in loops and recursions, such optimisation quickly pays
dividends).

-------------------------------------------------------------
Usage:

The Parser is incorporated in a class, which makes it thread-safe.
Since the parser is no longer needed once the document has been
decomposed, the DOM is implemented as a seperate class.  The parser
generates instances of the XML() class as required, and returns the
topmost object in the DOM tree.  This allows the parser to be
discarded once processing a document has been completed.

At the top of the source file is this construct:

#ifdef _TEST_
   Function Main(cFile)
      local oXml
      local nH
      if FExists(cFile)
         oXml := ParseXml( memoread(cFile) )
         if !oXml == NIL
            nH := FCreate('test.xml')
            FWrite(nH,oXml:asString())
            FClose(nH)
         endif
      endif
      return nil
#endif

You can compile the source as a stand-alone executable with this command
line:

xpp xmlparser /m /n /w /a /b /d_TEST_ /link:"/de"

The function ParseXml() accepts an input stream representing an XML
document - in the above code, this is implemented by reading the
document into memory via the MemoRead() function.  The return value of
this function is the top-level object in the heirarchy, which should
always be named '?xml'.

The methods exposed by the XML class are:

init
asString
compose
parent
children
getChild
allSiblings
siblings
getSibling
getPreviousSibling
getNextSibling
isOrphan
getAttribute
setAttribute
findAttribute
findChildFromName
findChildFromAttribute
findAllChildrenFromName
findSiblingFromName
findSiblingFromAttribute

