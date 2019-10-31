- BDE_SETUP.EXE 
  Borland Database Engine Installer
  File needed for the distribution of applications created 
  with Visual dBsee that requires the Borland Database Engine

- XML2XIT.EXE
  Converts an XML language file in XIT Visual dBsee language file format

- SAMPLE.XML
  XML language file to use with XML2XIT 
  contains only messages used during the creation of new forms/browse...

- ENGLISH.XML
  XML language file to use with XML2XIT 
  contains all messages used in Visual dBsee


How to translate messages used in Visual dBsee
----------------------------------------------
1) Copy SAMPLE.XML (or ENGLISH.XML) to USER.XML 
2) Edit the USER.XML file, translate to your language only the English text between the tags
   <translated> </translated> but DO NOT CHANGE the other tags and the text in Italian.
   Please note that the &apos; is REQUIRED and can't be deleted.
   Example:
      <xml>
         <messagefile>
            <type>HIT</type>
            <author>Visual dBsee Property Table</author>
            <language>English</language>
            <englishlanguage>English</englishlanguage>
            <langcode>en_US</langcode>
            <tablelen>2</tablelen>
            <table>
               <message>
                  <base>&apos;Impossibile lasciare vuoto il campo&apos;</base>
                  <translated>&apos;Can not leave empty field&apos;</translated>
               </message>
               <message>
                  <base>&apos;A^bbandona&apos;</base>
                  <translated>&apos;^Cancel&apos;</translated>
               </message>
            </table>
         </messagefile>
      </xml>

   Translated to SPANISH is:
      <xml>
         <messagefile>
            <type>HIT</type>
            <author>Visual dBsee Property Table</author>
            <language>English</language>
            <englishlanguage>English</englishlanguage>
            <langcode>en_US</langcode>
            <tablelen>2</tablelen>
            <table>
               <message>
                  <base>&apos;Impossibile lasciare vuoto il campo&apos;</base>
                  <translated>&apos;Imposible dejar vacio el campo&apos;</translated>
               </message>
               <message>
                  <base>&apos;A^bbandona&apos;</base>
                  <translated>&apos;^Renuncia&apos;</translated>
               </message>
            </table>
         </messagefile>
      </xml>

   The change is limited only to the 2 lines 
      <translated>&apos;Imposible dejar vacio el campo&apos;</translated>
      <translated>&apos;^Renuncia&apos;</translated>

3) Run 
   XML2XIT.EXE user.xml user.xit
4) Copy the user.xit in the Visual dBsee\BIN folder
