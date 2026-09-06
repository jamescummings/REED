<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="3.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:map="http://www.w3.org/2005/xpath-functions/map"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all">
  
  <!-- Output as proper HTML5 -->
  <xsl:output method="html" html-version="5.0" encoding="UTF-8" indent="yes"/>
  
  <!-- Language mapping variable -->
  <xsl:variable name="lang-labels" as="map(xs:string, xs:string)" select="
    map {
    'ang': 'Old English',
    'eng': 'English',
    'enm': 'Middle English',
    'lat': 'Latin',
    'fro': 'Old French',
    'fra': 'French',
    'frm': 'Middle French',
    'ita': 'Italian',
    'und': 'Undetermined-language'
    }"/>
  
  <xsl:template match="/">
    <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&#10;</xsl:text>
    <html lang="en">
      <head>
        <meta charset="UTF-8"/>
        <title>Medieval Abbreviations Dictionary</title>
        <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/jquery.dataTables.min.css"/>
        <style>
          body { font-family: sans-serif; padding: 20px; }
          .ex { font-style: italic; color: #555; } /* Style expanded abbreviations */
          /* Basic styling for footer search inputs */
          tfoot input { width: 100%; padding: 3px; box-sizing: border-box; }
          tfoot { display: table-header-group; } /* Moves search bars to top under headers */
        </style>
      </head>
      <body>
        <h2>Medieval Abbreviations</h2>
        <table id="dictionaryTable" class="display" style="width:100%">
          <thead>
            <tr>
              <th>ID</th>
              <th>Language</th>
              <th>Attestation</th>
              <th>Frequency</th>
              <th>References</th>
            </tr>
          </thead>
          <!-- Footer used for individual column search inputs -->
          <tfoot>
            <tr>
              <th>ID</th>
              <th>Language</th>
              <th>Attestation</th>
              <th>Frequency</th>
              <th>References</th>
            </tr>
          </tfoot>
          <tbody>
            <xsl:apply-templates select="//entry"/>
          </tbody>
        </table>
        
        <script src="https://code.jquery.com/jquery-3.7.0.min.js"></script>
        <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
        <script>
          $(document).ready(function() {
          // 1. Setup - add a text input to each footer cell
          $('#dictionaryTable tfoot th').each(function() {
          var title = $(this).text();
          $(this).html('&lt;input type="text" placeholder="Search ' + title + '" /&gt;');
          });
          
          // 2. Initialize DataTable
          var table = $('#dictionaryTable').DataTable({
          "pageLength": 25,
          "order": [[ 2, "asc" ]], // Order by Attestation by default
          initComplete: function () {
          // 3. Apply the search functionality to each column
          this.api().columns().every(function () {
          var that = this;
          $('input', this.footer()).on('keyup change clear', function () {
          if (that.search() !== this.value) {
          that.search(this.value).draw();
          }
          });
          });
          }
          });
          });
        </script>
      </body>
    </html>
  </xsl:template>
  
  <!-- Process individual dictionary entries -->
  <xsl:template match="entry">
    <tr>
      <!-- ID Column -->
      <td><xsl:value-of select="@xml:id"/></td>
      
      <!-- Language Column with Map Lookup -->
      <td>
        <xsl:variable name="code" select="string(@xml:lang)"/>
        <!-- Lookup code in map. If not found, default back to the raw code -->
        <xsl:value-of select="($lang-labels($code), $code)[1]"/>
      </td>
      
      <!-- Attestation Column -->
      <td><xsl:apply-templates select="form/orth"/></td>
      
      <!-- Frequency Column -->
      <td><xsl:value-of select="usg[@type='frequency']"/></td>
      
      <!-- References Column -->
      <td>
        <xsl:for-each select="cit/ref">
          <a href="{@target}" target="_blank">
            <xsl:value-of select="."/>
          </a>
          <xsl:if test="position() != last()">, </xsl:if>
        </xsl:for-each>
      </td>
    </tr>
  </xsl:template>
  
  <!-- Format Expanded Abbreviations -->
  <xsl:template match="ex">
    <span class="ex">(<xsl:apply-templates/>)</span>
  </xsl:template>
  
</xsl:stylesheet>