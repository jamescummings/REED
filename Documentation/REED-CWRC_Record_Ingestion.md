# How to Ingest a REED Record into CWRC
## (Version 1.0, 23 July 2020)

### Scope of Documentation
Before you begin, check the "Published Records — Tracking" google sheet for the list of records still to be ingested. Pick one and find it in the Word file of the relevant REED print volume. You will be copying the text there — along with any associated endnote or translation — and pasting it into an XML file. You may choose to paste it into a copy of the template.xml, which provides a template of the basic TEI structure that holds a REED record. As you become more familiar with the TEI, you may prefer to work in blank XML files with only the <teiHeader>. 

The workflow outlined in this document is as follows:

1. find the record you'd like to ingest in the Word file of the relevant REED print volume
1. copy-paste the material (the transcription with its marginalia and footnotes, along with any associated translation or endnote) into an XML file, either into template.xml or a blank XML file with only the `<teiHeader>`
1. proof the copied material and add further markup
1. add the record to CWRC by filling in the MODS fields and then ingesting
1. add the resulting URL to the "Published Records — Tracking" google sheet

To do this work, you will need an XML editor like oXygen and the Word files of REED's print volumes. You will also want access to these related documents:

- Published Records —Tracking (google sheet)
- template.xml
- TEI Quick Reference Chart
- How to Fill in MODS Fields: Born Digital Objects
- How to Fill in MODS Fields: Manuscript Objects

### Copy the Record into an XML File
Once you've found your record in the Word file of the relevant REED print volume, you are ready to begin. You will be copying the text of the transcription, along with any associated marginalia footnotes, translations, and endnotes, into an XML file.
	The basic TEI record structure includes three main sections: a `<div type="transcription">`, `<div type="translation">`, and `<div type="endnote">`. See template.xml for the full template including the `<teiHeader>`. Below is the record structure only:
	
```
<text type="record">
      <body>         
         <head>[Provide the record name and date as provided from the REED volume in this space
            (e.g., Gray's Inn Ledger Book, 1593–4)]</head>
         <div type="transcription">
            <div xml:lang="[add en, la, or fr as value of xml:lang]">
               <head>
                  <supplied>[Add headnote text and date here]</supplied>
               </head>
               <pb/>
               <gap reason="omitted"/>
               <ab>[Add text for transcription here]</ab>
               <gap reason="omitted"/>
            </div>
            <div xml:lang="[add en, la, or fr as value of xml:lang]">
               <head>
                  <supplied>[If there is a second record text add headnote text and date here -
                     otherwise remove this div and all content within]</supplied>
               </head>
               <pb/>
               <gap reason="omitted"/>
               <ab>[Add text for transcription here]</ab>
               <gap reason="omitted"/>
            </div>
         </div?
         <div xml:lang="en” type="translation">
            <gap reason="omitted"/>
            <ab>[Add text for translation here - otherwise remove this div tag and all content
               within]</ab>
            <gap reason="omitted"/>
         </div>
         <div type="endnote">
            <p>[Add text for endnote here - otherwise remove this div tag and all content
               within]</p>
         </div>
      </body>
   </text>

```
A simple marked-up record, from Nelson (ed), Inns of Court, p 114, looks like this:

```
 <text type="record">
      <body>
         <head>Lincoln's Inn Black Book 5, <date from-iso="1588" to-iso="1589">1588–9</date></head>
         <div type="transcription">
            <div xml:lang="la" >
               <head><supplied>f 445 <date from-iso="1588-11-21" to-iso="1589-11-22”>(21 November 1588–22 November 1589)</date> (Treasurer’s
                     payments)</supplied></head>
               <pb n="445" type="folio"/>
               <gap reason="omitted"/>
               <ab><note type="marginal" place="margin_left">Stipend<ex>ia</ex>
                     musicor<ex>um</ex></note>Et de <measure>xxvj s. viij d.</measure>
                     solut<ex>is</ex> Will<ex>elm</ex>o Perryn Music<ex>i</ex>on<ex>i</ex>
                     p<ex>ro</ex> Annual<ex>i</ex> stipend<ex>io</ex> ei Concess<ex>o</ex>
                     p<ex>er</ex> warrant<ex>um</ex> Gubernator<ex>um</ex> hospicij
                     p<ex>re</ex>d<ex>i</ex>c<ex>t</ex>i<lb/>
                  <hi rend="right">Summa <measure>xxvj s. viij d.</measure></hi></ab>
               <gap reason="omitted"/>
            </div>
         </div>
         <div xml:lang="en” type="translation">
            <div>
               <head><supplied>f 445 <date from-iso="1588-11-21" to-iso="1589-11-22”>(21 November 1588–22 November 1589)</date> (Treasurer’s
                     payments)</supplied></head>
               <pb n="445" type="folio"/>
               <gap reason="omitted"/>
               <ab><note type="marginal" place="margin_left">Musicians’ stipends</note>And (the
                  accountant seeks to be allowed the sum) of 26s 8d paid to William Perryn,
                  musician, for the annual stipend granted him by a warrant of the governors of the
                  aforesaid Inn.<lb/>
                  <hi rend="right">Total: 26s 8d</hi></ab>
               <gap reason="omitted"/>
            </div>
         </div>
         <div type="endnote">
            <p>No musicians’ roll is recorded this year because the steward, Ralph Metcallffe, left
               his position and failed to finish his accounts (f 443). But the money was no doubt
               collected by the musicians, as the new steward, Abraham Ripley, continued the custom
               the following year. </p>
         </div>
      </body>
   </text>

```
Some transcription content may be contained in a table (`<table>`), rather than an anonymous block (`<ab>`). Table markup is commonly used for accounts, where sums appear in the right-hand column and line-item descriptions in the left. Below is table markup for a table with one row and two columns (from Erler (ed), Ecclesiastical London, p 160). Note the sum has also been marked up with `<measure> </measure>` tags:
```
<text type="record">
      <body>
         <head>St Helen's Churchwardens' Accounts, <date from-iso="1585" to-iso="1586"
            >1585—6</date></head>
         <div type="transcription">
            <div xml:lang="en” >
               <head><supplied>f 42v (Payments)</supplied></head>
               <pb n="42v" type="folio"/>
               <gap reason="omitted"/>
               <table>
                  <row>
                     <cell>Item paid for dressinge of Mr Burdes Hobby</cell>
                     <cell><measure>iiij d.</measure>
                     </cell>
                  </row>
               </table>
               <gap reason="omitted"/>
            </div>
         </div>
         <div type="endnote">
            <p>This is the latest record of hobby-horse dancing in the London parish accounts.
               William Byrd and Thomas Colshill were churchwardens in 1573–4 (f 20). In 1574–5 a Mr
               Byrd was in arrears for the clerk’s wages (f 23) and in 1576–7 a Mr William Byrd was
               in arrears for both the lecture money and the clerk’s wages (f 26). </p>
         </div>
      </body>
   </text>

```
For an easily scanned list of our TEI markup and what it means, see the TEI Quick Reference Chart. (replace with link)

### Proof the Record and Complete the TEI Markup
Once you've copied the transcription into the appropriate sections of the XML file, you will need to proofread it against the original, so you can fix errors and add further markup. 
	One thing you will need to add to the copied text, as you proof, is expansion tags (`<ex></ex>`). In the print collections, italicized letters represented letters in abbreviated words that had been added or "expanded" by the editor. In XML, we indicate this by adding a pair of `<ex> </ex>` tags around any letters that were italicized in the print volume.
	Other paleographical symbols you will see frequently in the print volumes, and what you need to add as TEI markup instead, are listed here:

[insert image of you see / you change to ]

We have tried to include examples of all these tags in context in the sample records above. The Quick Reference Chart also provides a quick reference for these and more.
	You will also need to look for other glitches that happened during the copy-paste, for instance, extra spaces after italicized letter "r"s. These spaces need to be found and closed if the "r" was in the middle of a word in the print volume.
	Finally, you will need to add some additional markup that is not indicated with any symbols or characters in the print volume, for instance, dates and sums. These are noted below, along with additional notes about individual elements.
